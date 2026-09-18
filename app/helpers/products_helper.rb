module ProductsHelper
  # A low stock badge appears at or below this many units. It is a presentation
  # threshold, not a stocked/out-of-stock one, so it lives here and not on Variant.
  LOW_STOCK_THRESHOLD = 3

  # The cover when one is attached, otherwise a reserved placeholder of the
  # same box. The placeholder still carries a role and a label, so a screen
  # reader hears which product has no image rather than meeting an unlabelled
  # empty box.
  def product_cover_tag(product, size: :card)
    classes = cover_box_classes(size)
    return cover_image_tag(product, classes) if cover_attached?(product)

    tag.div(class: classes, role: "img", aria: { label: "#{product.name}: no image available" }) do
      tag.span("No image", class: "text-caption text-muted")
    end
  end

  # nil when the variant is comfortably stocked. A badge only when it is not,
  # so the grid stays quiet until something actually needs attention.
  def stock_label(variant)
    return tag.span("Sold out", class: "wt-badge wt-badge--ember") if variant.stock_quantity.zero?
    return tag.span("Low stock", class: "wt-badge wt-badge--accent") if variant.stock_quantity <= LOW_STOCK_THRESHOLD

    nil
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

    def cover_image_tag(product, classes)
      image_tag url_for(product.cover_image), alt: product.name, class: classes, loading: "lazy"
    end

    # Both sizes reserve an aspect box so a grid of cards keeps its rhythm
    # whether or not each product has a cover.
    def cover_box_classes(size)
      aspect = size == :detail ? "aspect-square" : "aspect-[4/5]"
      "#{aspect} flex w-full items-center justify-center rounded-xl border border-line bg-paper-sunk"
    end
end
