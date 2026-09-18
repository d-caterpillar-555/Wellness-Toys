require "rails_helper"

RSpec.describe DataRequestPolicy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :admin) }
  let(:data_request) { create(:data_request, user: owner) }

  it "allows the owner to read their own request" do
    expect(described_class.new(owner, data_request).show?).to be true
  end

  it "refuses another customer" do
    expect(described_class.new(other_user, data_request).show?).to be false
  end

  it "refuses staff through the storefront" do
    expect(described_class.new(staff, data_request).show?).to be false
  end

  it "refuses a guest" do
    expect(described_class.new(nil, data_request).show?).to be false
  end

  it "allows a signed-in person to make a request" do
    expect(described_class.new(owner, DataRequest).create?).to be true
    expect(described_class.new(nil, DataRequest).create?).to be false
  end

  it "scopes to the actor's own requests" do
    mine = create(:data_request, user: owner)
    create(:data_request, user: other_user)

    expect(described_class::Scope.new(owner, DataRequest).resolve).to contain_exactly(mine)
  end
end
