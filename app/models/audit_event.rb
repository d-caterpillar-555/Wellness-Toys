class AuditEvent < ApplicationRecord
  # Audit metadata is deliberately PII-free: a trail that copies a customer's
  # email or address is a second copy of the data it audits. This list is a real
  # rejection in record, not a naming convention to be honoured by hand.
  FORBIDDEN_METADATA_KEYS = %w[
    email name phone address line1 line2 postal_code note body password token
  ].freeze

  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :action, presence: true

  scope :chronological, -> { order(:created_at, :id) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :for_action, ->(action) { where(action: action) }

  class << self
    def record(action:, actor: nil, subject: nil, ip: nil, metadata: {})
      reject_pii!(metadata)
      create!(
        action: action,
        actor: actor,
        subject: subject,
        ip_hash: ip && Digest::SHA256.hexdigest(ip.to_s),
        metadata: metadata
      )
    end

    private
      def reject_pii!(metadata)
        offending = forbidden_keys(metadata)
        if offending.any?
          raise ArgumentError, "audit metadata must not contain #{offending.sort.join(', ')}"
        end
      end

      # Keys are scanned at every depth, so nesting a value under an innocent
      # name does not smuggle PII past the guard.
      def forbidden_keys(value)
        keys = case value
        when Hash then value.flat_map { |key, nested| [ key.to_s, *forbidden_keys(nested) ] }
        when Array then value.flat_map { |nested| forbidden_keys(nested) }
        else []
        end
        keys & FORBIDDEN_METADATA_KEYS
      end
  end

  # The table has no updated_at and is append-only, so a persisted row must never
  # be saved again.
  def readonly?
    persisted?
  end
end
