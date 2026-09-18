require "rails_helper"

# The public surfaces are readable by everyone and changeable by nobody through
# the storefront. The scopes are the part that matters: they are what keeps
# drafts, retired products and unpublished writing out of the shop.
RSpec.describe "Public content policies" do
  let(:guest) { nil }
  let(:customer) { create(:user) }
  let(:staff) { create(:user, :admin) }

  describe ProductPolicy do
    it "allows anyone to read the catalogue" do
      expect(described_class.new(guest, Product).index?).to be true
      expect(described_class.new(guest, Product.new).show?).to be true
    end

    it "refuses writes from every storefront actor" do
      policy = described_class.new(staff, Product.new)

      expect(policy.create?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end

    it "scopes to available products only" do
      available = create(:product, :with_variant)
      draft = create(:product, status: "draft", published_at: nil)

      resolved = described_class::Scope.new(guest, Product).resolve

      expect(resolved).to include(available)
      expect(resolved).not_to include(draft)
    end
  end

  describe ArticlePolicy do
    it "scopes to published, kept writing" do
      published = create(:article, :published)
      draft = create(:article)
      discarded = create(:article, :published)
      discarded.discard

      resolved = described_class::Scope.new(guest, Article).resolve

      expect(resolved).to include(published)
      expect(resolved).not_to include(draft, discarded)
    end
  end

  describe CategoryPolicy do
    it "scopes to kept categories" do
      kept = create(:category)
      discarded = create(:category)
      discarded.discard

      expect(described_class::Scope.new(guest, Category).resolve).to include(kept)
      expect(described_class::Scope.new(guest, Category).resolve).not_to include(discarded)
    end
  end

  describe TopicPolicy, AuthorPolicy do
    it "scopes to kept rows" do
      topic = create(:topic)
      author = create(:author)

      expect(TopicPolicy::Scope.new(guest, Topic).resolve).to include(topic)
      expect(AuthorPolicy::Scope.new(guest, Author).resolve).to include(author)
    end
  end

  describe PagePolicy do
    it "scopes to published pages" do
      suffix = SecureRandom.hex(4)
      live = Page.create!(slug: "live-#{suffix}", title: "Live", body: "Text", published_at: 1.day.ago)
      future = Page.create!(slug: "later-#{suffix}", title: "Later", body: "Text", published_at: 1.day.from_now)

      resolved = described_class::Scope.new(guest, Page).resolve

      expect(resolved).to include(live)
      expect(resolved).not_to include(future)
    end

    it "allows the home surface to everyone" do
      expect(described_class.new(guest, :page).home?).to be true
    end
  end

  describe SearchPolicy, CollectionPolicy do
    it "allows the surface to everyone" do
      expect(SearchPolicy.new(guest, :search).show?).to be true
      expect(CollectionPolicy.new(guest, :collection).show?).to be true
    end
  end
end
