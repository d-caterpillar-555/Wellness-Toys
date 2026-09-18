class ConsentRecord < ApplicationRecord
  KINDS = %w[functional analytics marketing].freeze

  belongs_to :user, optional: true

  validates :subject_token, :kind, :granted_at, :policy_version, presence: true
  validates :kind, inclusion: { in: KINDS }

  scope :chronological, -> { order(:created_at, :id) }

  class << self
    # IP and user agent are stored only as digests: enough to answer a dispute,
    # not enough to identify a visitor from the log.
    def grant(subject_token:, kind:, policy_version:, user: nil, ip: nil, user_agent: nil)
      create!(
        subject_token: subject_token,
        kind: kind,
        policy_version: policy_version,
        user: user,
        granted_at: Time.current,
        ip_hash: hash_or_nil(ip),
        user_agent_hash: hash_or_nil(user_agent)
      )
    end

    # Withdrawal is a second record, never an edit: the grant row and its
    # timestamp stay exactly as written.
    def withdraw(subject_token:, kind:, policy_version:, user: nil, ip: nil, user_agent: nil)
      create!(
        subject_token: subject_token,
        kind: kind,
        policy_version: policy_version,
        user: user,
        granted_at: grant_time_for(subject_token, kind),
        revoked_at: Time.current,
        ip_hash: hash_or_nil(ip),
        user_agent_hash: hash_or_nil(user_agent)
      )
    end

    def current_for(subject_token:)
      KINDS.index_with do |kind|
        row = latest_for(subject_token, kind)
        row.present? && row.revoked_at.nil?
      end
    end

    def granted?(subject_token:, kind:)
      row = latest_for(subject_token, kind)
      row.present? && row.revoked_at.nil?
    end

    private
      def latest_for(subject_token, kind)
        chronological.where(subject_token: subject_token, kind: kind).last
      end

      # A withdrawal carries the original grant time forward rather than now, so
      # the revoked_after_granted CHECK holds and the history reads as a timeline.
      def grant_time_for(subject_token, kind)
        latest_for(subject_token, kind)&.granted_at || Time.current
      end

      def hash_or_nil(value)
        value.present? ? Digest::SHA256.hexdigest(value.to_s) : nil
      end
  end

  # The table is append-only, enforced by a Postgres trigger that raises on
  # UPDATE and DELETE. Refusing to save a persisted record keeps the trigger a
  # backstop rather than the only line of defence.
  def readonly?
    persisted?
  end

  def revoked?
    revoked_at.present?
  end
end
