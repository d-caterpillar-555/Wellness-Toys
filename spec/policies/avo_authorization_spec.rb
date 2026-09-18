require "rails_helper"

# The adapter that answers Avo's authorization questions with this app's Pundit
# policies. Avo Community permits everything by default, so these are the tests
# that prove the console is actually gated.
RSpec.describe Avo::PunditAuthorization do
  let(:staff) { create(:user, :admin) }
  let(:customer) { create(:user) }

  describe "console actions" do
    it "allows staff to run the console actions a content policy permits" do
      authorization = described_class.new(staff, Product)

      expect(authorization.authorize(:index)).to be true
      expect(authorization.authorize(:new)).to be true
      expect(authorization.authorize(:create)).to be true
      expect(authorization.authorize(:update)).to be true
    end

    it "refuses a customer, and raises when the caller wants an exception" do
      authorization = described_class.new(customer, Product)

      expect(authorization.authorize(:index, raise_exception: false)).to be false
      expect { authorization.authorize(:update) }.to raise_error(Avo::NotAuthorizedError)
    end

    it "refuses an order destroy for staff, because an order is a record not a draft" do
      authorization = described_class.new(staff, create(:order))

      expect(authorization.authorize(:destroy, raise_exception: false)).to be false
      expect(authorization.authorize(:update)).to be true
    end

    it "asks the console question, not the storefront one" do
      # A guest may read the catalogue (ProductPolicy#show?), but that answer must
      # not leak into "may this person open the product in the console".
      authorization = described_class.new(nil, Product)

      expect(authorization.authorize(:show, raise_exception: false)).to be false
    end
  end

  describe "association actions" do
    it "reports whether the policy answers a question at all" do
      authorization = described_class.new(staff, Product)

      expect(authorization.has_method?(:index)).to be true
      expect(authorization.has_method?(:reorder_variants)).to be false
    end
  end

  describe "scoping" do
    it "narrows the index to what the policy scope returns" do
      available = create(:product, :with_variant)
      draft = create(:product, status: "draft", published_at: nil)

      resolved = described_class.new(staff, Product).apply_policy(Product.all)

      expect(resolved).to include(available)
      expect(resolved).not_to include(draft)
    end

    it "resolves to nothing when the model has no policy scope" do
      expect(described_class.new(staff, User).apply_policy(User.all)).to be_empty
    end
  end

  describe "missing policies" do
    it "raises rather than permitting" do
      # Active Storage's models have no policy, which is what an unconfigured
      # resource looks like.
      authorization = described_class.new(staff, ActiveStorage::Blob)

      expect { authorization.authorize(:index) }.to raise_error(Avo::NoPolicyError)
    end
  end
end
