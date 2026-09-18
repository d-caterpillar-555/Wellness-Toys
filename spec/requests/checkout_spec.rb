require "rails_helper"

RSpec.describe "Checkout", type: :request do
  let(:variant) { create(:variant, price_cents: 2_500, stock_quantity: 5) }

  def add_to_cart(item, quantity: 1)
    post cart_items_path, params: { variant_id: item.id, quantity: quantity }
  end

  def checkout_params(token: SecureRandom.uuid, **overrides)
    {
      checkout: {
        checkout_token: token,
        email: "buyer@example.com",
        ship_to_recipient: "A. Customer",
        ship_to_line1: "12 Alder Road",
        ship_to_city: "Bristol",
        ship_to_postal_code: "BS1 4ST",
        ship_to_country_code: "gb"
      }.merge(overrides)
    }
  end

  describe "GET /checkout" do
    it "renders the form when the cart has something in it" do
      add_to_cart(variant)

      get new_checkout_path

      expect(response).to have_http_status(:ok)
      expect(page_text).to include(I18n.t("checkout.title"))
    end

    it "sends an empty cart back to the cart with a message" do
      get new_checkout_path

      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(page_text).to include(I18n.t("checkout.empty_cart"))
    end
  end

  describe "POST /checkout" do
    it "places one order, takes the stock, empties the cart and redirects to it" do
      add_to_cart(variant, quantity: 2)

      expect {
        post checkout_path, params: checkout_params
      }.to change(Order, :count).by(1)

      order = Order.kept.last
      expect(order.email).to eq("buyer@example.com")
      # The ISO code column is upper case at the database level; the form sends
      # what a person typed.
      expect(order.ship_to_country_code).to eq("GB")
      expect(order.order_items.count).to eq(1)
      expect(order.subtotal_cents).to eq(5_000)
      expect(order.total_cents).to eq(5_000)
      expect(order.status).to eq("pending")
      expect(order.order_events.pluck(:kind)).to include("created")
      expect(variant.reload.stock_quantity).to eq(3)
      expect(CartItem.count).to eq(0)
      expect(response).to redirect_to(order_path(order.public_token))
    end

    it "enqueues the confirmation email" do
      add_to_cart(variant)

      expect {
        post checkout_path, params: checkout_params
      }.to have_enqueued_job(OrderConfirmationJob)
    end

    it "treats a double submit as one order and redirects to the first" do
      add_to_cart(variant)
      token = SecureRandom.uuid

      post checkout_path, params: checkout_params(token: token)
      first_order = Order.kept.last

      expect {
        post checkout_path, params: checkout_params(token: token)
      }.not_to change(Order, :count)

      expect(response).to redirect_to(order_path(first_order.public_token))
    end

    it "rolls the whole order back when a line has sold out" do
      add_to_cart(variant, quantity: 2)
      variant.update!(stock_quantity: 1)

      expect {
        post checkout_path, params: checkout_params
      }.not_to change(Order, :count)

      expect(response).to have_http_status(422)
      expect(variant.reload.stock_quantity).to eq(1)
      expect(page_text).to include(variant.product.name)
    end

    it "creates nothing when the details are incomplete" do
      add_to_cart(variant)

      expect {
        post checkout_path, params: checkout_params(ship_to_line1: "")
      }.not_to change(Order, :count)

      expect(response).to have_http_status(422)
      expect(page_text).to include(I18n.t("checkout.errors_heading"))
    end

    it "sends an empty cart back to the cart without creating an order" do
      expect {
        post checkout_path, params: checkout_params
      }.not_to change(Order, :count)

      expect(response).to redirect_to(cart_path)
    end
  end
end
