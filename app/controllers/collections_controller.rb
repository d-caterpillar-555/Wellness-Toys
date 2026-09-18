class CollectionsController < ApplicationController
  # PLACEHOLDER: a Collection is a curated, human-chosen grouping of products
  # (see docs/domain-terms.md). There is no Collection model or table yet, so
  # this allowlist stands in for one. Each entry derives its set from real
  # catalogue data instead of a hand-maintained join table. Replace this with
  # a Collection model once curation needs to be edited without a deploy.
  COLLECTIONS = {
    "new" => {
      title: "New arrivals",
      description: "The eight products most recently added to the catalogue."
    },
    "body-safe" => {
      title: "Body safe",
      description: "Products finished so they can be used on and in the body."
    },
    "under-50" => {
      title: "Under $50",
      description: "Products with at least one configuration under fifty dollars."
    }
  }.freeze

  def show
    authorize :collection, :show?
    raise ActiveRecord::RecordNotFound unless COLLECTIONS.key?(params[:slug])

    @collection = COLLECTIONS.fetch(params[:slug])
    @products = collection_products
  end

  private
    def collection_products
      return newest_arrivals if params[:slug] == "new"
      return Product.available.with_catalogue.body_safe_only.newest_first if params[:slug] == "body-safe"

      Product.available.with_catalogue.with_variant_under(5_000).newest_first
    end

    def newest_arrivals
      Product.available.with_catalogue.newest_first.limit(8)
    end
end
