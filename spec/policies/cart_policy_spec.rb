require "rails_helper"

RSpec.describe CartPolicy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :admin) }
  let(:guest_cart) { create(:cart) }
  let(:account_cart) { create(:cart, :for_user, user: owner) }

  it "allows a guest cart to be read and changed" do
    policy = described_class.new(nil, guest_cart)

    expect(policy.show?).to be true
    expect(policy.update?).to be true
  end

  it "allows the account's own cart" do
    policy = described_class.new(owner, account_cart)

    expect(policy.show?).to be true
    expect(policy.update?).to be true
  end

  it "refuses another customer's account cart" do
    policy = described_class.new(other_user, account_cart)

    expect(policy.show?).to be false
    expect(policy.update?).to be false
  end

  it "refuses staff, because a cart is not an administrative surface" do
    expect(described_class.new(staff, account_cart).show?).to be false
  end

  it "scopes to the actor's own cart" do
    theirs = create(:cart, :for_user, user: other_user)

    expect(described_class::Scope.new(owner, Cart).resolve).to contain_exactly(account_cart)
    expect(described_class::Scope.new(owner, Cart).resolve).not_to include(theirs)
  end
end
