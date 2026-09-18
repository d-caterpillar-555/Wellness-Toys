require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /learn/:topic_slug/:slug" do
    it "renders the article and its evidence rail, one entry per source" do
      topic = create(:topic, name: "Sexual health basics")
      article = create(:article, :published, :with_sources,
        primary_topic: topic,
        title: "Materials explained",
        excerpt: "What each material does in practice.")
      article.topics << topic

      get learn_article_path(topic, article)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Materials explained")
      expect(response.body).to include("sources-heading")
      expect(response.body.scan('rel="noopener noreferrer"').size).to eq(article.sources.size)
    end

    it "does not render the rail heading when the article cites nothing" do
      topic = create(:topic, name: "Communication and consent")
      article = create(:article, :published, primary_topic: topic, title: "An uncited piece")
      article.topics << topic

      get learn_article_path(topic, article)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("This piece does not cite external sources.")
      expect(response.body).not_to include("sources-heading")
    end

    it "returns 404 for an article slug that does not exist" do
      topic = create(:topic)

      get learn_article_path(topic, "not-a-real-article")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the article exists outside the given topic" do
      topic = create(:topic, name: "Contraception")
      other_topic = create(:topic, name: "Pleasure and anatomy")
      article = create(:article, :published, primary_topic: other_topic, title: "Filed elsewhere")
      article.topics << other_topic

      get learn_article_path(topic, article)

      expect(response).to have_http_status(:not_found)
    end
  end
end
