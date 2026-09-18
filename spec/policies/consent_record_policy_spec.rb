require "rails_helper"

RSpec.describe ConsentRecordPolicy do
  let(:account) { create(:user) }
  let(:other_user) { create(:user) }
  let(:record) { create(:consent_record, user: account) }

  it "allows anyone, including a guest, to record a consent decision" do
    expect(described_class.new(nil, ConsentRecord).create?).to be true
    expect(described_class.new(account, ConsentRecord).create?).to be true
  end

  it "allows a signed-in person to read and record consent for their own account" do
    policy = described_class.new(account, record)

    expect(policy.index?).to be true
    expect(policy.update?).to be true
  end

  it "refuses a guest" do
    policy = described_class.new(nil, record)

    expect(policy.index?).to be false
    expect(policy.update?).to be false
  end

  it "scopes to the actor's own records, which is what keeps accounts apart" do
    mine = create(:consent_record, user: account)
    create(:consent_record, user: other_user)
    create(:consent_record)

    expect(described_class::Scope.new(account, ConsentRecord).resolve).to contain_exactly(mine)
    expect(described_class::Scope.new(other_user, ConsentRecord).resolve).not_to include(mine)
  end
end
