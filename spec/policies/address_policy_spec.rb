require "rails_helper"

RSpec.describe AddressPolicy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :admin) }
  let(:address) { create(:address, user: owner) }

  describe "#index?" do
    it "allows any signed-in person" do
      expect(described_class.new(owner, Address).index?).to be true
    end

    it "refuses a guest" do
      expect(described_class.new(nil, Address).index?).to be false
    end
  end

  describe "#show?, #update?, #destroy?" do
    it "allows the owner" do
      policy = described_class.new(owner, address)

      expect(policy.show?).to be true
      expect(policy.update?).to be true
      expect(policy.destroy?).to be true
    end

    it "refuses another customer" do
      policy = described_class.new(other_user, address)

      expect(policy.show?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end

    it "refuses staff, because an address is not an administrative surface" do
      expect(described_class.new(staff, address).show?).to be false
    end

    it "refuses a guest" do
      expect(described_class.new(nil, address).show?).to be false
    end
  end

  describe "#create?" do
    it "allows any signed-in person" do
      expect(described_class.new(owner, Address).create?).to be true
    end

    it "refuses a guest" do
      expect(described_class.new(nil, Address).create?).to be false
    end
  end

  describe "Scope" do
    it "returns only the actor's own addresses" do
      mine = create(:address, user: owner)
      create(:address, user: other_user)

      expect(described_class::Scope.new(owner, Address).resolve).to contain_exactly(mine)
    end

    it "returns nothing for a guest" do
      create(:address, user: owner)

      expect(described_class::Scope.new(nil, Address).resolve).to be_empty
    end
  end
end
