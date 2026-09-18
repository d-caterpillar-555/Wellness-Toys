require "rails_helper"

RSpec.describe "Glossary", type: :request do
  describe "GET /learn/glossary" do
    it "groups published terms by their first letter and offers a jump list" do
      create(:article, :published, :glossary, title: "Zygosity and you")

      get learn_glossary_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Zygosity and you")
      expect(response.body).to include("letter-z")
    end

    it "leaves a draft term out" do
      create(:article, :glossary, title: "A draft definition")

      get learn_glossary_path

      expect(response.body).not_to include("A draft definition")
    end
  end

  describe "GET /learn/glossary/:term" do
    it "renders a published glossary term" do
      term = create(:article, :published, :glossary, title: "Dental dam", excerpt: "A barrier sheet.")

      get learn_glossary_term_path(term)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dental dam")
    end

    it "returns 404 for an unknown term" do
      get learn_glossary_term_path("not-a-real-term")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for an article that is not a glossary term" do
      guide = create(:article, :published, :guide, title: "A guide, not a term")

      get learn_glossary_term_path(guide)

      expect(response).to have_http_status(:not_found)
    end
  end
end
