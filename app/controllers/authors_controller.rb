class AuthorsController < ApplicationController
  def index
    @authors = policy_scope(Author).ordered.with_published_article_count
  end

  def show
    @author = policy_scope(Author).find_by!(slug: params[:slug])
    authorize @author
    @articles = @author.published_articles.kept.with_reading_list
  end
end
