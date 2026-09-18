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

  # The full subtree, children first at each level. Memoised because a
  # navigation tree reads it several times per request.
  def descendants
    @descendants ||= children.flat_map { |child| [ child, *child.descendants ] }
  end

  def root?
    parent_id.nil?
  end
end
