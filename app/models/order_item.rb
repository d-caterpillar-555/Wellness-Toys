class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :variant, optional: true

  before_validation :snapshot_from_variant, on: :create
  before_validation :compute_line_total

  validates :product_name, :variant_name, :sku, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  def self.build_from_cart_item(cart_item)
    new(
      variant: cart_item.variant,
      quantity: cart_item.quantity,
      unit_price_cents: cart_item.unit_price_cents,
      line_total_cents: cart_item.line_total_cents
    )
  end

  private
    # An order line is a snapshot, not a live reference: it copies the variant's
    # values at purchase time so a later price or name change never rewrites
    # what the customer actually bought.
    def snapshot_from_variant
      return if variant.blank?

      self.product_name ||= variant.product.name
      self.variant_name ||= variant.name
      self.sku ||= variant.sku
      self.unit_price_cents ||= variant.price_cents
      self.currency ||= variant.currency
    end

    def compute_line_total
      self.line_total_cents = unit_price_cents * quantity
    end
end
