class Order < ApplicationRecord
  include Discard::Model

  # A plain string guarded by a database CHECK constraint. A Rails enum would
  # restate the list in Ruby and give it a second source of truth.
  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze

  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :order_events, -> { order(:created_at) }, dependent: :destroy, inverse_of: :order

  encrypts :note

  before_validation :assign_identifiers, on: :create

  validates :number, presence: true, uniqueness: true
  validates :public_token, presence: true, uniqueness: true, length: { minimum: 22 }
  validates :status, inclusion: { in: STATUSES }

  # The database holds these NOT NULL, but a blank string satisfies NOT NULL.
  # Validating here turns an empty submission into a form error instead of an
  # order persisted with no address and no email to invoice.
  validates :email, :ship_to_recipient, :ship_to_line1, :ship_to_city,
    :ship_to_postal_code, :ship_to_country_code, :checkout_token, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :awaiting_invoice, -> { where(payment_status: "awaiting_invoice") }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :processing, -> { where(status: "processing") }
  scope :shipped, -> { where(status: "shipped") }
  scope :delivered, -> { where(status: "delivered") }
  scope :cancelled, -> { where(status: "cancelled") }

  # The public token is the only credential a guest holds, so an unknown token
  # is a not-found rather than a forbidden.
  def self.find_by_public_token!(token)
    kept.find_by!(public_token: token)
  end

  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def processing?
    status == "processing"
  end

  def shipped?
    status == "shipped"
  end

  def delivered?
    status == "delivered"
  end

  def cancelled?
    status == "cancelled"
  end

  # Idempotent: a repeated call is a no-op rather than a second confirmation
  # event, so a retried checkout cannot double-record the transition.
  def place!(actor: nil)
    return if confirmed?

    transaction do
      update!(status: "confirmed", placed_at: Time.current)
      record_event!(kind: "confirmed", actor: actor)
    end
  end

  def recalculate_totals!
    subtotal = order_items.sum("unit_price_cents * quantity")
    update!(subtotal_cents: subtotal, total_cents: subtotal + shipping_cents + tax_cents)
  end

  def item_count
    order_items.sum(:quantity)
  end

  def record_event!(kind:, actor: nil, note: nil)
    order_events.create!(kind: kind, actor: actor, note: note, to_status: status)
  end

  private
    def assign_identifiers
      self.number ||= generate_number
      self.public_token ||= SecureRandom.urlsafe_base64(24)
    end

    def generate_number
      sequence = SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")
      "WT-#{Time.current.year}-#{sequence}"
    end
end
