class CategoriesController < ApplicationController
  PER_PAGE = 12

  def show
    @category = policy_scope(Category).find_by!(slug: params[:category_slug])
    authorize @category
    @children = @category.children.kept.ordered
    @pagy, @products = pagy(:offset, catalogue, limit: PER_PAGE)
  end

  private
    def catalogue
      @category.products.available.with_catalogue.newest_first
    end
end
