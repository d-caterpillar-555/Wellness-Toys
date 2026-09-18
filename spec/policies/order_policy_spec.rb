require "rails_helper"

RSpec.describe OrderPolicy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :admin) }
  let(:order) { create(:order, user: owner) }

  describe "the public receipt" do
    it "is readable by a guest holding the token" do
      expect(described_class.new(nil, order).receipt?).to be true
    end

    it "is readable by anyone else holding the token, which is the point of a capability" do
      expect(described_class.new(other_user, order).receipt?).to be true
    end
  end

  describe "#show?" do
    it "allows the owner" do
      expect(described_class.new(owner, order).show?).to be true
    end

    it "refuses another customer" do
      expect(described_class.new(other_user, order).show?).to be false
    end

    it "allows staff" do
      expect(described_class.new(staff, order).show?).to be true
    end

    it "refuses a guest" do
      expect(described_class.new(nil, order).show?).to be false
    end
  end

  describe "#create?" do
    it "allows a guest to place an order" do
      expect(described_class.new(nil, Order).create?).to be true
    end

    it "allows a customer to place an order" do
      expect(described_class.new(other_user, Order).create?).to be true
    end
  end

  describe "Scope" do
    it "returns only the actor's own orders" do
      mine = create(:order, user: owner)
      create(:order, user: other_user)
      create(:order)

      expect(described_class::Scope.new(owner, Order).resolve).to contain_exactly(mine)
    end

    it "returns nothing for a guest" do
      create(:order, user: owner)

      expect(described_class::Scope.new(nil, Order).resolve).to be_empty
    end
  end
end
