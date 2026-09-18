require "rails_helper"

RSpec.describe "Account addresses", type: :request do
  let(:user) { create(:user) }

  def address_params(**overrides)
    {
      address: {
        recipient: "Rae Lindqvist",
        line1: "12 Alder Road",
        city: "Bristol",
        postal_code: "BS1 4ST",
        country_code: "GB"
      }.merge(overrides)
    }
  end

  it "sends a signed-out visitor to sign in" do
    get account_addresses_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "lists only the account's own addresses" do
    mine = create(:address, user: user, recipient: "Mine")
    create(:address, recipient: "Theirs")
    sign_in user

    get account_addresses_path

    expect(page_text).to include("Mine")
    expect(page_text).not_to include("Theirs")
  end

  it "creates an address stored encrypted" do
    sign_in user

    expect {
      post account_addresses_path, params: address_params
    }.to change(user.addresses, :count).by(1)

    address = user.addresses.kept.last
    expect(address.line1).to eq("12 Alder Road")
    raw = Address.connection.select_value("SELECT line1 FROM addresses WHERE id = #{address.id}")
    expect(raw).not_to include("Alder")
  end

  it "makes the first address the default shipping address on request" do
    sign_in user

    post account_addresses_path, params: address_params(default_shipping: "1")

    expect(user.addresses.kept.default_shipping.count).to eq(1)
  end

  it "moves the default shipping flag rather than adding a second one" do
    first = create(:address, :default_shipping, user: user)
    second = create(:address, user: user)
    sign_in user

    patch account_address_path(second), params: address_params(default_shipping: "1")

    expect(second.reload.default_shipping?).to be true
    expect(first.reload.default_shipping?).to be false
  end

  it "updates an address" do
    address = create(:address, user: user)
    sign_in user

    patch account_address_path(address), params: address_params(city: "Bath")

    expect(address.reload.city).to eq("Bath")
  end

  it "discards an address rather than deleting the row" do
    address = create(:address, user: user)
    sign_in user

    expect {
      delete account_address_path(address)
    }.not_to change(Address, :count)

    expect(Address.kept.find_by(id: address.id)).to be_nil
  end

  it "returns 404 for another account's address" do
    theirs = create(:address)
    sign_in user

    get edit_account_address_path(theirs)

    expect(response).to have_http_status(:not_found)
  end

  it "refuses a country code that is not two letters" do
    sign_in user

    expect {
      post account_addresses_path, params: address_params(country_code: "GBR")
    }.not_to change(Address, :count)

    expect(response).to have_http_status(422)
  end
end
