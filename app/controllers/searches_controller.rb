class SearchesController < ApplicationController
  PER_PAGE = 12
  ARTICLE_LIMIT = 5

  def show
    authorize :search, :show?
    @query = params[:q].to_s.strip
    return if @query.blank?

    @pagy, @products = pagy(:offset, product_results, limit: PER_PAGE)
    @articles = article_results
  end

  private
    def product_results
      policy_scope(Product).with_catalogue.search_by_text(@query).newest_first
    end

    # Education is cross-linked from search results, not mixed into them: a
    # reader looking for a product and a reader looking for an explanation are
    # served better by two labelled groups than by one ranked list.
    def article_results
      # The result list shows a title and its kind, not a byline, so only the
      # topic is loaded.
      policy_scope(Article).search_by_title(@query).includes(:primary_topic).recent_first.limit(ARTICLE_LIMIT)
    end
end
