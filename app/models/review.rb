class Review < ApplicationRecord
  include Discard::Model

  STATUSES = %w[pending approved rejected].freeze

  belongs_to :product
  belongs_to :user

  validates :rating, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :product_id }
  validates :body, length: { maximum: 2000 }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }

  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }
  scope :kept_active, -> { kept }
  scope :recent_first, -> { order(created_at: :desc) }

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end

  # Approval and its timestamp move together, since the database refuses an
  # approved review with no published_at.
  def publish!
    transaction do
      update!(status: "approved", published_at: Time.current)
    end
  end

  # Reviews are ordered by recency, never by a manual position, so this stays a
  # constant rather than an editor-controlled value.
  def reorder_marker
    0
  end
end
