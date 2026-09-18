class NewsletterSubscriber < ApplicationRecord
  include Discard::Model

  normalizes :email, with: ->(value) { value.to_s.strip.downcase.presence }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :consented_at, presence: true

  scope :subscribed, -> { kept.where(unsubscribed_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }

  def subscribe!
    update!(unsubscribed_at: nil)
  end

  def unsubscribe!
    update!(unsubscribed_at: Time.current)
  end
end
