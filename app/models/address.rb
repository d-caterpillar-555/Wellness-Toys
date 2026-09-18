class Address < ApplicationRecord
  include Discard::Model

  encrypts :line1, :line2

  belongs_to :user

  validates :recipient, :line1, :city, :postal_code, :country_code, presence: true
  validates :country_code, length: { is: 2 }
  validate :defaults_are_distinct

  scope :kept_active, -> { kept }
  scope :default_shipping, -> { kept.where(default_shipping: true) }
  scope :default_billing, -> { kept.where(default_billing: true) }
  scope :recent_first, -> { order(created_at: :desc) }

  # A single line for display and for pasting onto a shipping label. The street
  # lines arrive already decrypted by the encrypted attribute type.
  def one_line
    [ recipient, line1, line2, city, region, postal_code, country_code ].compact_blank.join(", ")
  end

  def make_default_shipping!
    transaction do
      user.addresses.kept.where.not(id: id).update_all(default_shipping: false)
      update!(default_shipping: true)
    end
  end

  def make_default_billing!
    transaction do
      user.addresses.kept.where.not(id: id).update_all(default_billing: false)
      update!(default_billing: true)
    end
  end

  private
    # Mirrors the addresses_defaults_are_distinct CHECK so a form shows a
    # readable error instead of a raising INSERT.
    def defaults_are_distinct
      if default_shipping? && default_billing?
        errors.add(:base, "an address cannot be both the default shipping and billing address")
      end
    end
end
