class OrderEvent < ApplicationRecord
  KINDS = %w[created confirmed processing shipped delivered cancelled note refunded].freeze

  belongs_to :order, inverse_of: :order_events
  belongs_to :actor, class_name: "User", optional: true

  validates :kind, presence: true
  validates :to_status, inclusion: { in: Order::STATUSES }, allow_nil: true

  scope :chronological, -> { order(:created_at) }

  def self.record!(order, kind:, actor: nil, note: nil, to_status: nil)
    order.order_events.create!(kind: kind, actor: actor, note: note, to_status: to_status)
  end
end
