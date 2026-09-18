require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /shop" do
    it "lists available products and leaves drafts out" do
      create(:product, :with_variant, name: "Available Product")
      create(:product, name: "Draft Product", status: "draft", published_at: nil)

      get shop_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Available Product")
      expect(response.body).not_to include("Draft Product")
    end

    it "filters the catalogue by brand slug" do
      kept_brand = create(:brand, name: "Northlight")
      other_brand = create(:brand, name: "Corvid")
      create(:product, :with_variant, brand: kept_brand, name: "Kept Product")
      create(:product, :with_variant, brand: other_brand, name: "Other Product")

      get shop_path(brand: kept_brand.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Kept Product")
      expect(response.body).not_to include("Other Product")
    end

    it "renders the filtered empty state when a brand has no products" do
      empty_brand = create(:brand)

      get shop_path(brand: empty_brand.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nothing matches this filter yet")
    end

    it "renders the catalogue empty state when nothing is available" do
      # Stubbed rather than emptied: the shared test database carries seed data,
      # and deleting products would trip Active Storage's purge callbacks.
      allow(Product).to receive(:available).and_return(Product.none)

      get shop_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("The catalogue is empty right now")
    end
  end

  describe "GET /shop/:category_slug/:slug" do
    it "renders the monograph with its specifications" do
      category = create(:category, name: "Lubricants")
      product = create(:product, :with_variant, name: "Water Based Lubricant", materials: "Medical grade silicone")
      product.categories << category

      get product_path(category, product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Water Based Lubricant")
      expect(response.body).to include("Materials and safety")
      expect(response.body).to include("Medical grade silicone")
    end

    it "renders an honest empty state when there are no reviews" do
      category = create(:category)
      product = create(:product, :with_variant)
      product.categories << category

      get product_path(category, product)

      expect(response.body).to include("No reviews here yet")
    end

    it "returns 404 for a product slug that does not exist" do
      category = create(:category)

      get product_path(category, "not-a-real-product")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the product exists outside the given category" do
      product = create(:product, :with_variant)
      other_category = create(:category, name: "Massage")

      get product_path(other_category, product)

      expect(response).to have_http_status(:not_found)
    end
  end
end
