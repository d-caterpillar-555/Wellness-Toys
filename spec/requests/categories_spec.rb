require "rails_helper"

RSpec.describe "Categories", type: :request do
  describe "GET /shop/:category_slug" do
    it "lists the products filed under the category" do
      category = create(:category, name: "Lubricants")
      product = create(:product, :with_variant, name: "Water Based Lubricant")
      product.categories << category

      get category_path(category)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lubricants")
      expect(response.body).to include("Water Based Lubricant")
    end

    it "shows the child categories" do
      parent = create(:category, name: "Body")
      create(:category, name: "Massage oils", parent: parent)

      get category_path(parent)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Massage oils")
    end

    it "renders the empty state when the category holds no products" do
      category = create(:category, name: "Empty shelf")

      get category_path(category)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nothing in this category yet")
    end

    it "returns 404 for a category slug that does not exist" do
      get category_path("not-a-real-category")

      expect(response).to have_http_status(:not_found)
    end
  end
end
