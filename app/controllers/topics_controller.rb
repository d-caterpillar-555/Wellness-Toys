class TopicsController < ApplicationController
  LATEST_GUIDES = 3
  RECENT_POSTS = 3

  def index
    @topics = policy_scope(Topic).ordered.with_published_article_count
    @latest_guides = policy_scope(Article).guides.with_reading_list.recent_first.limit(LATEST_GUIDES)
  end

  def show
    @topic = policy_scope(Topic).find_by!(slug: params[:topic_slug])
    authorize @topic
    @articles_by_kind = published_articles.group_by(&:kind)
    @children = @topic.children.kept.ordered
    @recent_posts = policy_scope(Article).posts.recent_first.limit(RECENT_POSTS)
  end

  private
    def published_articles
      @topic.published_articles.kept.with_reading_list.recent_first
    end
end
