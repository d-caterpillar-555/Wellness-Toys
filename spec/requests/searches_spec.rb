require "rails_helper"

RSpec.describe "Search", type: :request do
  describe "GET /search" do
    it "renders the form and no results when no query is given" do
      get search_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Search terms")
      expect(response.body).not_to include("From the library")
    end

    it "treats a whitespace-only query as no query" do
      get search_path(q: "   ")

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("From the library")
    end

    it "returns products whose name matches" do
      create(:product, :with_variant, name: "Water Based Lubricant")
      create(:product, :with_variant, name: "Silicone Massage Oil")

      get search_path(q: "lubricant")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Water Based Lubricant")
      expect(response.body).not_to include("Silicone Massage Oil")
    end

    it "matches on the subtitle as well as the name" do
      create(:product, :with_variant, name: "Everyday Product", subtitle: "Fragrance free lubricant")

      get search_path(q: "fragrance")

      expect(response.body).to include("Everyday Product")
    end

    it "renders the empty state when nothing matches" do
      get search_path(q: "nothingmatchesthisatall")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nothing matches")
    end

    it "treats the ILIKE wildcard as a literal character" do
      create(:product, :with_variant, name: "Water Based Lubricant")

      get search_path(q: "%")

      expect(response.body).to include("Nothing matches")
    end

    it "surfaces matching articles from the library" do
      Article.create!(
        title: "Understanding lubricant ingredients",
        kind: "guide",
        status: "published",
        published_at: 1.day.ago
      )

      get search_path(q: "lubricant")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("From the library")
      expect(response.body).to include("Understanding lubricant ingredients")
    end
  end
end
