require "rails_helper"

RSpec.describe "Topics", type: :request do
  describe "GET /learn" do
    it "lists each topic with its published article count" do
      topic = create(:topic, name: "Communication and consent")
      2.times { |n| create(:article, :published, title: "Published piece #{n}", primary_topic: topic).topics << topic }

      get learn_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Communication and consent")
      expect(response.body).to include("2 articles")
    end

    it "surfaces the latest guides" do
      create(:article, :published, :guide, title: "Reading a materials list", published_at: Time.current)

      get learn_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reading a materials list")
    end

    it "links through to the glossary and the writers" do
      get learn_path

      expect(response.body).to include(learn_glossary_path)
      expect(response.body).to include(learn_experts_path)
    end
  end

  describe "GET /learn/:topic_slug" do
    it "groups the topic's published articles by kind" do
      topic = create(:topic, name: "Pleasure and anatomy")
      guide = create(:article, :published, :guide, title: "A gentle guide", primary_topic: topic)
      guide.topics << topic
      term = create(:article, :published, :glossary, title: "A defined term", primary_topic: topic)
      term.topics << topic

      get learn_topic_path(topic)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A gentle guide")
      expect(response.body).to include("A defined term")
    end

    it "leaves a draft article out" do
      topic = create(:topic, name: "Sexual wellbeing")
      draft = create(:article, title: "An unpublished draft", primary_topic: topic, status: "draft")
      draft.topics << topic

      get learn_topic_path(topic)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("An unpublished draft")
    end

    it "returns 404 for a topic slug that does not exist" do
      get learn_topic_path("not-a-real-topic")

      expect(response).to have_http_status(:not_found)
    end
  end
end
