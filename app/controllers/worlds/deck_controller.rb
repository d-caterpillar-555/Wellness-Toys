module Worlds
  # deck: the shop as a control room.
  #
  # A console, not a brochure: a sidebar, a top bar, and the catalogue as a
  # table you filter and sort without leaving the page. The server renders the
  # table (so it is real HTML and works without JavaScript), and publishes the
  # same records as data so the console can filter, sort, open a record in a
  # side sheet and put it in the basket without a round trip.
  class DeckController < BaseController
    world "deck"

    def index
      @objects = catalogue
      @departments = departments
      @reading = library(limit: 8)
      @records = records
    end

    def item
      @product = catalogue.find_by!(slug: params[:slug])
      @variants = @product.variants.select(&:active?)
      @department = @product.primary_category
      @related = catalogue.for_category(@department&.slug).where.not(id: @product.id).limit(4)
      @objects = catalogue
      @departments = departments
      @reading = library(limit: 8)
      @records = records
    end

    def reading
      @reading = library(limit: 40)
      @departments = departments
      @objects = catalogue
      @records = records
    end

    def paperwork
      @pages = Page::ROUTED_SLUGS.filter_map { |slug| page_for(slug) }
      @departments = departments
      @objects = catalogue
      @records = records
    end

    private

    # The console's data: one row per object, with everything the table, the
    # side sheet and the basket need.
    def records
      @records ||= catalogue.map do |product|
        variants = product.variants.select(&:active?)

        {
          slug: product.slug,
          name: product.name,
          sku: product.sku,
          department: product.primary_category&.name || "Catalogue",
          maker: product.brand&.name,
          price_cents: product.lowest_price_cents,
          price: helpers.strip_tags(helpers.price(product.lowest_price_cents)),
          body_safe: product.body_safe?,
          in_stock: product.in_stock?,
          materials: product.materials,
          dimensions: product.dimensions,
          safety: product.safety_notes,
          description: product.description,
          url: deck_item_path(product.slug),
          variant_id: variants.first&.id,
          editions: variants.map { |variant| { id: variant.id, name: variant.name, price: helpers.strip_tags(helpers.price(variant.price_cents, currency: variant.currency)) } },
          cart_url: helpers.cart_items_path
        }
      end
    end
  end
end
