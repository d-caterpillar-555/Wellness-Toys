class Variant < ApplicationRecord
  include Discard::Model

  class OutOfStockError < StandardError; end

  belongs_to :product, inverse_of: :variants

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :price_cents, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { kept.where(active: true) }
  scope :in_stock, -> { where("stock_quantity > 0") }
  scope :ordered, -> { order(:position, :name) }

  def in_stock?
    stock_quantity.positive?
  end

  def on_sale?
    compare_at_price_cents.present? && compare_at_price_cents > price_cents
  end

  def discount_percent
    return 0 unless on_sale?

    ((compare_at_price_cents - price_cents) * 100.0 / compare_at_price_cents).round
  end

  # Atomic by design: the decrement and the availability check happen in one
  # conditional UPDATE, so two concurrent checkouts can never both pass a
  # read-then-write guard and oversell the last unit.
  def decrement_stock!(quantity)
    raise ArgumentError, "quantity must be positive" unless quantity.positive?

    updated = self.class.where(id: id)
                        .where("stock_quantity >= ?", quantity)
                        .update_all("stock_quantity = stock_quantity - #{quantity.to_i}, updated_at = NOW()")

    raise OutOfStockError, "#{sku} does not have #{quantity} available" if updated.zero?

    reload
  end
end
