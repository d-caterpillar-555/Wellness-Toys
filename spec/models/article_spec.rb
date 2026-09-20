require "rails_helper"

RSpec.describe Article, type: :model do
  # sources_count is a counter cache: the shell and the console print it, and a
  # list that says "3 src" must not load three rows to say it.
  describe "sources_count" do
    it "counts the sources attached to the article" do
      article = create(:article)

      expect { create_list(:source, 2, article: article) }
        .to change { article.reload.sources_count }.from(0).to(2)
    end

    it "counts back down when a source is removed" do
      article = create(:article, :with_sources)

      expect { article.sources.first.destroy }
        .to change { article.reload.sources_count }.from(2).to(1)
    end
  end
end
