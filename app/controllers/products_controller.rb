class ProductsController < ApplicationController
  PER_PAGE = 12

  def index
    @brands = Brand.kept_active.alphabetical
    @category = Category.kept.find_by(slug: params[:category])
    @brand = Brand.kept.find_by(slug: params[:brand])
    @pagy, @products = pagy(:offset, catalogue, limit: PER_PAGE)
  end

  def show
    @product = monograph
    authorize @product
    @primary_category = @product.primary_category
    @variants = @product.variants.select(&:active?)
    @reviews = @product.reviews.approved.kept_active.recent_first
    @faqs = @product.faqs.kept_active.ordered
  end

  private
    def catalogue
      relation = policy_scope(Product).with_catalogue.newest_first
      relation = relation.for_category(params[:category]) if params[:category].present?
      relation = relation.for_brand(params[:brand]) if params[:brand].present?
      relation
    end

    # A product is reachable only under a category, so when the request carries
    # a category slug the product must belong to it or the pair is a 404.
    def monograph
      relation = policy_scope(Product).with_catalogue
      slug = params[:category_slug]
      relation = relation.for_category(slug) if slug.present?
      relation.find_by!(slug: params[:slug])
    end
end
