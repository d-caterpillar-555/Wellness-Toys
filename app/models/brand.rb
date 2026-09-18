# The maker of a Product.
#
# NOT to be confused with `Store` (app/models/store.rb), which holds this
# shop's own trading identity. See docs/domain-terms.md.
class Brand < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :kept_active, -> { kept }
  scope :alphabetical, -> { order(:name) }
  scope :with_products, -> { kept.joins(:products).distinct }

  def to_param
    slug
  end

  def product_count
    products.kept.count
  end
end
