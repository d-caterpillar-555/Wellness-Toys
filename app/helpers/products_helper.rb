module ProductsHelper
  # A low stock badge appears at or below this many units. It is a presentation
  # threshold, not a stocked/out-of-stock one, so it lives here and not on Variant.
  LOW_STOCK_THRESHOLD = 3

  # The cover when one is attached; otherwise a plate that has not been printed
  # yet. A grey box reading "No image" is the loudest element on a catalogue
  # page and says nothing, so a missing photograph is drawn as an archival
  # plate: the frame stays, the label is centred, and the object is identified.
  #
  # The caller owns the frame (see the .wt-specimen wrapper); this returns the
  # content that goes inside it.
  def product_cover_tag(product)
    return cover_image_tag(product) if cover_attached?(product)
    return catalogue_render_tag(product) if catalogue_render_for(product)

    tag.div(
      class: "wt-specimen--empty h-full w-full",
      role: "img",
      aria: { label: "#{product.name}: photograph not supplied" }
    ) do
      tag.span(class: "wt-specimen__plate-label") do
        safe_join([
          tag.span("Photograph not supplied", class: "wt-register"),
          tag.span(product.sku, class: "wt-numeral text-title")
        ])
      end
    end
  end

  # nil when the variant is comfortably stocked. A badge only when it is not,
  # so the grid stays quiet until something actually needs attention.
  def stock_label(variant)
    return tag.span("Sold out", class: "wt-mark wt-mark--ember") if variant.stock_quantity.zero?
    return tag.span("Low stock", class: "wt-mark wt-mark--accent") if variant.stock_quantity <= LOW_STOCK_THRESHOLD

    nil
  end

  # The catalogue ships with one studio rendering per product, made from
  # scratch for this shop. They are not photographs, and nothing in the markup
  # or the alt text claims they are: a rendering of the form is what this
  # catalogue honestly has until real photography exists.
  def catalogue_render_for(product)
    name = "catalogue/#{product.slug}.png"
    return nil unless Rails.application.assets.load_path&.find(name)

    name
  end

  def catalogue_render_tag(product)
    image_tag catalogue_render_for(product),
      alt: "#{product.name}, studio rendering",
      class: "h-full w-full object-cover",
      loading: "lazy",
      decoding: "async"
  end

  private
    # Active Storage is declared on Product, but its tables are not migrated in
    # every environment yet. Checking the table first means we never run a query
    # that raises UndefinedTable, which matters because a raised query aborts
    # the surrounding transaction and takes every later query in the request
    # with it. A missing store reads as "no cover", which is the truth.
    def cover_attached?(product)
      active_storage_ready? && product.cover_image.attached?
    end

    def active_storage_ready?
      return @active_storage_ready unless @active_storage_ready.nil?

      @active_storage_ready = ActiveStorage::Attachment.table_exists?
    end

    def cover_image_tag(product)
      image_tag url_for(product.cover_image),
        alt: product.name,
        class: "h-full w-full object-cover",
        loading: "lazy"
    end
end
