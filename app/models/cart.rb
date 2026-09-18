class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :variants, through: :cart_items

  before_validation :ensure_guest_token, on: :create

  # A cart is held by exactly one owner: a signed-in customer or an anonymous
  # guest. The database enforces the same invariant with a CHECK constraint,
  # so this validation exists only to produce a readable error.
  validate :exactly_one_owner

  scope :for_guest, ->(token) { where(guest_token: token) }
  scope :for_user, ->(user) { where(user: user) }
  scope :stale, -> { where("carts.updated_at < ?", 30.days.ago) }

  # Adding a variant already in the cart bumps that line instead of colliding
  # with the unique index over (cart_id, variant_id).
  def add_variant!(variant, quantity: 1)
    raise ArgumentError, "quantity must be positive" unless quantity.positive?

    transaction do
      item = cart_items.find_or_initialize_by(variant: variant)
      # A new row already carries the column default of 1, so the first add sets
      # the quantity instead of adding to that default. The cap matches the
      # database CHECK: the line is clamped rather than handed to an INSERT that
      # would raise.
      current = item.persisted? ? item.quantity : 0
      item.quantity = [ current + quantity, CartItem::MAX_QUANTITY ].min
      item.save!
      item
    end
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def subtotal_cents
    cart_items.joins(:variant).sum("cart_items.quantity * variants.price_cents")
  end

  def empty?
    cart_items.none?
  end

  def merge_into!(other_cart)
    transaction do
      cart_items.find_each do |item|
        target = other_cart.cart_items.find_or_initialize_by(variant_id: item.variant_id)
        # A fresh line starts at zero here, not at its column default of 1, and
        # a merged total obeys the same cap as any other line.
        current = target.persisted? ? target.quantity : 0
        target.quantity = [ current + item.quantity, CartItem::MAX_QUANTITY ].min
        target.save!
      end

      destroy!
    end
  end

  private
    def ensure_guest_token
      if user.blank? && guest_token.blank?
        self.guest_token = SecureRandom.urlsafe_base64(24)
      end
    end

    def exactly_one_owner
      if user.present? == guest_token.present?
        errors.add(:base, "must belong to a customer or a guest token, never both and never neither")
      end
    end
end
