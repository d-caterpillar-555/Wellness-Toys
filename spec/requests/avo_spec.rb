require "rails_helper"

RSpec.describe "Admin console", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:editor) { create(:user, :editor) }
  let(:customer) { create(:user) }

  describe "reaching the console at all" do
    it "sends a signed-out visitor to sign in" do
      get "/admin"

      expect(response).to redirect_to(new_user_session_path)
    end

    it "sends a signed-in customer back to the shop" do
      sign_in customer

      get "/admin"

      # Written as a literal: Avo's engine defines a root of its own, and
      # `root_path` inside a request spec resolves to that one.
      expect(response).to redirect_to("/")
    end

    it "admits an admin, landing them on a resource they may manage" do
      sign_in admin

      get "/admin"
      follow_redirect!

      expect(response).to have_http_status(:ok)
    end

    it "admits an editor, because content is their job" do
      sign_in editor

      get "/admin/resources/products"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "authorization inside the console" do
    it "lists the resources a staff member may manage" do
      product = create(:product, :with_variant)
      sign_in admin

      get "/admin/resources/products"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end

    it "refuses to destroy an order, even for an admin" do
      order = create(:order)
      sign_in admin

      delete "/admin/resources/orders/#{order.id}"

      expect(response).not_to have_http_status(:ok)
      expect(Order.exists?(order.id)).to be true
    end

    it "keeps credentials off the order screen" do
      order = create(:order)
      sign_in admin

      get "/admin/resources/orders/#{order.id}"

      expect(response.body).not_to include(order.public_token)
      expect(response.body).not_to include(order.checkout_token)
    end
  end
end
