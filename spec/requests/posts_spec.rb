require "rails_helper"

RSpec.describe "Blog posts", type: :request do
  describe "GET /blog" do
    it "lists published posts newest first" do
      create(:article, :published, :post, title: "An older post", published_at: 5.days.ago)
      create(:article, :published, :post, title: "A newer post", published_at: 1.hour.ago)

      get blog_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A newer post")
      expect(response.body.index("A newer post")).to be < response.body.index("An older post")
    end

    it "leaves a draft post out" do
      create(:article, :post, title: "A draft post", status: "draft", published_at: nil)

      get blog_path

      expect(response.body).not_to include("A draft post")
    end
  end

  describe "GET /blog/:slug" do
    it "renders a published post" do
      article = create(:article, :published, :post, title: "A timely piece", excerpt: "Short and current.")

      get blog_post_path(article)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A timely piece")
    end

    it "returns 404 for a slug that does not exist" do
      get blog_post_path("not-a-real-post")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a guide, which is not a post" do
      guide = create(:article, :published, :guide, title: "A guide, not a post")

      get blog_post_path(guide)

      expect(response).to have_http_status(:not_found)
    end
  end
end
