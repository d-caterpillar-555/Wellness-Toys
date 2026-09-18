require "rails_helper"

RSpec.describe "Authors", type: :request do
  describe "GET /learn/experts" do
    it "lists authors with their published article counts" do
      author = create(:author, name: "Sam Okonjo")
      create(:article, :published, author: author, title: "A credited guide")
      create(:article, author: author, title: "An unpublished draft")

      get learn_experts_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sam Okonjo")
      expect(response.body).to include("1 article")
    end
  end

  describe "GET /learn/experts/:slug" do
    it "renders the author with their published articles" do
      author = create(:author, name: "Rae Lindqvist", bio: "DEMO. Writes about communication.")
      create(:article, :published, author: author, title: "Talking plainly")

      get learn_expert_path(author)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Rae Lindqvist")
      expect(response.body).to include("Talking plainly")
    end

    it "renders credentials only when the writer has stated them" do
      blank = create(:author, name: "Wren Alcott")

      get learn_expert_path(blank)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Credentials")

      stated = create(:author, name: "Has Credentials", credentials: "Registered nurse, twelve years")

      get learn_expert_path(stated)

      expect(response.body).to include("Registered nurse, twelve years")
    end

    it "returns 404 for an author slug that does not exist" do
      get learn_expert_path("not-a-real-author")

      expect(response).to have_http_status(:not_found)
    end
  end
end
