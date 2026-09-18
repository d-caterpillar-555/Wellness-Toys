class ArticlesController < ApplicationController
  RELATED_LIMIT = 3

  def show
    @topic = policy_scope(Topic).find_by!(slug: params[:topic_slug])
    @article = article_scope.with_evidence.find_by!(slug: params[:slug])
    authorize @article
    @related = related_articles
  end

  private
    def article_scope
      @topic.published_articles.kept.with_reading_list
    end

    # Same primary topic, never itself. An article with no primary topic has
    # nothing to be related to, which is an empty list and not an error.
    def related_articles
      return Article.none if @article.primary_topic.nil?

      @article.primary_topic.published_articles.kept
        .where.not(id: @article.id)
        .with_reading_list.recent_first.limit(RELATED_LIMIT)
    end
end
