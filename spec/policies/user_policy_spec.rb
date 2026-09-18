require "rails_helper"

RSpec.describe UserPolicy do
  let(:account) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :admin) }

  it "allows the account holder to read and change their own account" do
    policy = described_class.new(account, account)

    expect(policy.show?).to be true
    expect(policy.update?).to be true
  end

  it "refuses another customer" do
    policy = described_class.new(other_user, account)

    expect(policy.show?).to be false
    expect(policy.update?).to be false
  end

  it "refuses staff through the storefront, whatever their role" do
    policy = described_class.new(staff, account)

    expect(policy.show?).to be false
    expect(policy.update?).to be false
  end

  it "refuses a guest" do
    expect(described_class.new(nil, account).show?).to be false
  end
end
