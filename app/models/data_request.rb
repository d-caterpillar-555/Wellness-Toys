class DataRequest < ApplicationRecord
  KINDS = %w[export delete].freeze
  STATUSES = %w[pending processing completed rejected].freeze

  belongs_to :user

  # The generated copy of a person's data. It is written to a storage service of
  # its own rather than the one holding product imagery, so no route that serves
  # the shop can ever serve somebody's export.
  has_one_attached :export, service: :exports

  before_validation :set_requested_at, on: :create

  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }
  validates :requested_at, presence: true

  scope :open_requests, -> { where(status: %w[pending processing]) }
  scope :completed, -> { where(status: "completed") }
  scope :recent_first, -> { order(requested_at: :desc) }

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def rejected?
    status == "rejected"
  end

  def open?
    status == "pending" || status == "processing"
  end

  # Completion and its timestamp move together, since the database refuses a
  # completed request with no completed_at.
  def complete!(note: nil)
    transaction do
      update!(status: "completed", completed_at: Time.current, note: note.presence || self.note)
    end
  end

  def reject!(note:)
    transaction do
      update!(status: "rejected", note: note)
    end
  end

  def overdue?
    open? && requested_at.present? && requested_at < 30.days.ago
  end

  def export_ready?
    export.attached?
  end

  private
    def set_requested_at
      self.requested_at ||= Time.current
    end
end
