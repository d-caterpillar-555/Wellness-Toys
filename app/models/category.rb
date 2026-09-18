class Category < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children,
    class_name: "Category",
    foreign_key: :parent_id,
    inverse_of: :parent,
    dependent: :nullify
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  scope :kept_and_published, -> { kept.ordered }

  # What the catalogue register on the home page prints: every kept category
  # with the number of products a visitor could actually buy, in one query
  # rather than a count per row. The LEFT JOIN keeps an empty category in the
  # register, because an empty shelf is a fact worth showing.
  scope :with_catalogue_count, -> {
    joins(
      "LEFT JOIN product_categories counted_product_categories " \
      "ON counted_product_categories.category_id = categories.id"
    )
      .joins(
        "LEFT JOIN products counted_products ON counted_products.id = counted_product_categories.product_id " \
        "AND counted_products.status = 'active' AND counted_products.published_at <= NOW() " \
        "AND counted_products.discarded_at IS NULL"
      )
      .group("categories.id")
      .select("categories.*", "COUNT(counted_products.id) AS catalogue_count")
  }

  # The full subtree, children first at each level. Memoised because a
  # navigation tree reads it several times per request.
  def descendants
    @descendants ||= children.flat_map { |child| [ child, *child.descendants ] }
  end

  def root?
    parent_id.nil?
  end

  # The grouped count when the register loaded it, and an honest count
  # otherwise, so a category reads correctly wherever it is used.
  def catalogue_count
    self[:catalogue_count] || products.available.count
  end
end
