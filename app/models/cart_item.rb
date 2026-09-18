class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :variant

  # One owner for the range the database CHECK enforces, so the model, the
  # controller and the constraint cannot drift apart.
  MIN_QUANTITY = 1
  MAX_QUANTITY = 100

  # Insertion order rather than id alone, so a cart reads the way it was built.
  scope :in_order, -> { order(:created_at, :id) }

  validates :quantity, numericality: { greater_than_or_equal_to: MIN_QUANTITY, less_than_or_equal_to: MAX_QUANTITY }
  validates :variant_id, uniqueness: { scope: :cart_id }

  def line_total_cents
    variant.price_cents * quantity
  end

  def unit_price_cents
    variant.price_cents
  end
end
