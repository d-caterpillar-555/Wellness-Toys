require "rails_helper"

RSpec.describe "Cart", type: :request do
  describe "GET /cart" do
    it "renders the empty state for a visitor who has added nothing" do
      get cart_path

      expect(response).to have_http_status(:ok)
      expect(page_text).to include(I18n.t("cart.empty_heading"))
    end

    it "lists the variants already in the cart with their line totals" do
      variant = create(:variant, price_cents: 2_500)
      post cart_items_path, params: { variant_id: variant.id, quantity: 2 }

      get cart_path

      expect(page_text).to include(variant.product.name)
      expect(page_text).to include("$50.00")
    end
  end

  describe "POST /cart/items" do
    it "adds the variant and redirects back to the cart" do
      variant = create(:variant)

      expect {
        post cart_items_path, params: { variant_id: variant.id, quantity: 1 }
      }.to change(CartItem, :count).by(1)

      expect(response).to redirect_to(cart_path)
    end

    it "bumps the existing line rather than adding a second one" do
      variant = create(:variant)

      post cart_items_path, params: { variant_id: variant.id, quantity: 1 }
      expect {
        post cart_items_path, params: { variant_id: variant.id, quantity: 2 }
      }.not_to change(CartItem, :count)

      expect(CartItem.last.quantity).to eq(3)
    end

    it "clamps a quantity above the cart maximum instead of raising" do
      variant = create(:variant, stock_quantity: 500)

      post cart_items_path, params: { variant_id: variant.id, quantity: 1_000 }

      expect(CartItem.last.quantity).to eq(100)
    end

    it "refuses more than the available stock and adds nothing" do
      variant = create(:variant, stock_quantity: 1)

      expect {
        post cart_items_path, params: { variant_id: variant.id, quantity: 2 }
      }.not_to change(CartItem, :count)

      # A plain HTML submit is answered with a redirect and a flash, the way a
      # form submission is answered everywhere else on this site.
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to include(variant.product.name)
    end

    it "answers a Turbo submit with 422 and the message in the replaced flash" do
      variant = create(:variant, stock_quantity: 1)

      post cart_items_path,
        params: { variant_id: variant.id, quantity: 2 },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(422)
      expect(response.body).to include(I18n.t("cart.items.out_of_stock", product: variant.product.name))
    end

    it "renders the cart regions as Turbo Streams when Turbo asks for them" do
      variant = create(:variant)

      post cart_items_path,
        params: { variant_id: variant.id, quantity: 1 },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('turbo-stream action="replace" target="cart-count"')
    end

    it "returns 404 for a variant that does not exist" do
      post cart_items_path, params: { variant_id: 0, quantity: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /cart/items/:id" do
    it "updates the quantity" do
      variant = create(:variant)
      post cart_items_path, params: { variant_id: variant.id, quantity: 1 }
      item = CartItem.last

      patch cart_item_path(item), params: { quantity: 4 }

      expect(item.reload.quantity).to eq(4)
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "DELETE /cart/items/:id" do
    it "removes the line" do
      variant = create(:variant)
      post cart_items_path, params: { variant_id: variant.id, quantity: 1 }
      item = CartItem.last

      expect {
        delete cart_item_path(item)
      }.to change(CartItem, :count).by(-1)

      expect(response).to redirect_to(cart_path)
    end
  end

  describe "guest cart and account cart" do
    it "folds a guest cart into the account cart on sign in, once" do
      variant = create(:variant)
      user = create(:user)
      post cart_items_path, params: { variant_id: variant.id, quantity: 2 }

      sign_in user

      get cart_path
      expect(page_text).to include(variant.product.name)
      expect(user.cart.cart_items.sum(:quantity)).to eq(2)

      get cart_path
      expect(user.cart.cart_items.sum(:quantity)).to eq(2)
    end
  end
end
