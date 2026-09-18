class PostsController < ApplicationController
  PER_PAGE = 10

  def index
    # Cards carry a byline and a topic, so both are loaded with the list.
    @pagy, @posts = pagy(:offset, posts_scope.with_reading_list, limit: PER_PAGE)
  end

  def show
    # The page itself renders the body and the evidence rail, not the byline.
    @post = posts_scope.with_evidence.find_by!(slug: params[:slug])
    authorize @post
  end

  private
    def posts_scope
      policy_scope(Article).posts.recent_first
    end
end
