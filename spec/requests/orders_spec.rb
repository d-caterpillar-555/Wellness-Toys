require "rails_helper"

RSpec.describe "Orders", type: :request do
  describe "GET /orders/:public_token" do
    it "shows the order to anyone holding its public token" do
      order = create(:order, :with_item)

      get order_path(order.public_token)

      expect(response).to have_http_status(:ok)
      expect(page_text).to include(order.number)
      expect(page_text).to include(order.order_items.first.product_name)
    end

    it "does not accept the sequential order number as the credential" do
      order = create(:order)

      get order_path(order.number)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for an unknown token" do
      get order_path("not-a-real-token")

      expect(response).to have_http_status(:not_found)
    end
  end
end
