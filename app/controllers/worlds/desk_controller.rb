module Worlds
  # desk: the shop as a conversation.
  #
  # The page is a transcript with a concierge. The script itself lives in the
  # browser (worlds/desk.js) because it is navigation, not data; what the server
  # publishes is the shelf - every object with the line that introduces it - so
  # the answers are always the real catalogue and the search can always fall
  # through to it.
  #
  # The concierge is a script and says so. It is not a clinician, it does not
  # give advice, and every answer it gives is also a link.
  class DeskController < BaseController
    world "desk"

    def index
      @departments = departments
      @shelf = shelf_index
      @reading = library(limit: 6)
    end

    def shelf
      @departments = departments
      @shelf = shelf_index
      @objects = catalogue
    end

    def item
      @product = catalogue.find_by!(slug: params[:slug])
      @variants = @product.variants.select(&:active?)
      @department = @product.primary_category
      @related = catalogue.for_category(@department&.slug).where.not(id: @product.id).limit(3)
      @departments = departments
      @shelf = shelf_index
    end

    private

    # What the concierge can offer: one line per object, its department, and the
    # price. Deliberately short - the transcript is not a data dump.
    def shelf_index
      @shelf_index ||= catalogue.map do |product|
        variants = product.variants.select(&:active?)

        {
          name: product.name,
          slug: product.slug,
          department: product.primary_category&.name || "Catalogue",
          department_slug: product.primary_category&.slug,
          price: helpers.strip_tags(helpers.price(product.lowest_price_cents)),
          line: product.description.presence || product.subtitle.presence || "No description recorded yet.",
          url: desk_item_path(product.slug),
          variant_id: variants.first&.id,
          cart_url: helpers.cart_items_path,
          editions: variants.map { |variant| variant.name }
        }
      end
    end
  end
end
