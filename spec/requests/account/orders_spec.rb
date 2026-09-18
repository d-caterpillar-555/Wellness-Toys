require "rails_helper"

RSpec.describe "Account orders", type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, :with_item, user: user) }

  it "sends a signed-out visitor to sign in" do
    get account_orders_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "lists the account's own orders" do
    order
    create(:order, email: "someone-else@example.com")
    sign_in user

    get account_orders_path

    expect(response).to have_http_status(:ok)
    expect(page_text).to include(order.number)
    expect(page_text).not_to include("someone-else")
  end

  it "shows one of the account's own orders" do
    sign_in user

    get account_order_path(order.number)

    expect(response).to have_http_status(:ok)
    expect(page_text).to include(order.number)
    expect(page_text).to include(order.order_items.first.product_name)
  end

  it "returns 404 for another account's order number" do
    theirs = create(:order)
    sign_in user

    get account_order_path(theirs.number)

    expect(response).to have_http_status(:not_found)
  end
end
