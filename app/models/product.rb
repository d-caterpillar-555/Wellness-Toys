class Product < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :brand, optional: true
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :variants, -> { order(:position) }, dependent: :destroy, inverse_of: :product
  has_many :reviews, dependent: :destroy
  has_many :faqs, as: :faqable, dependent: :destroy

  has_one_attached :cover_image

  accepts_nested_attributes_for :variants, allow_destroy: true, reject_if: :all_blank

  validates :name, :slug, :sku, presence: true
  validates :slug, uniqueness: true
  validates :sku, uniqueness: true

  # status is a plain string guarded by a database CHECK constraint. A Rails
  # enum would restate that list in Ruby and give it a second source of truth.
  scope :draft, -> { where(status: "draft") }
  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :published, -> { where(status: "active").where(published_at: ..Time.current) }
  scope :available, -> { published.kept }
  scope :newest_first, -> { order(published_at: :desc) }
  scope :alphabetical, -> { order(:name) }
  # Eager loads everything a product card renders so index pages stay N+1 free.
  scope :with_catalogue, -> { includes(:brand, :categories, :variants, :cover_image_attachment) }

  # Catalogue filters. Each is a scope so controllers and views never compose
  # raw SQL, and each uses a subquery rather than a join so a page that is also
  # eager loading the association does not fan the result set out.
  scope :for_category, ->(slug) {
    where(id: ProductCategory.joins(:category).where(categories: { slug: slug }).select(:product_id))
  }
  scope :for_brand, ->(slug) { where(brand_id: Brand.where(slug: slug).select(:id)) }
  scope :body_safe_only, -> { where(body_safe: true) }
  scope :with_variant_under, ->(cents) {
    where(id: Variant.kept.where("price_cents < ?", cents).select(:product_id))
  }

  # Postgres ILIKE over the two display fields. This is the fallback path: it
  # needs no external service, so search works before Meilisearch is wired in
  # (a later phase), which will take over relevance ranking and typo tolerance.
  scope :search_by_text, ->(query) {
    pattern = "%#{Product.sanitize_sql_like(query.to_s)}%"
    where("name ILIKE :q OR subtitle ILIKE :q", q: pattern)
  }

  def draft?
    status == "draft"
  end

  def active?
    status == "active"
  end

  def archived?
    status == "archived"
  end

  # The next three read from the eager-loaded association when a catalogue page
  # has already loaded it, and fall back to a query otherwise. That is what
  # keeps a grid of cards N+1 free without hiding the query from other callers.
  def lowest_price_cents
    return variants.min_by(&:price_cents)&.price_cents if variants.loaded?

    variants.minimum(:price_cents)
  end

  def in_stock?
    return variants.any?(&:in_stock?) if variants.loaded?

    variants.where("stock_quantity > 0").exists?
  end

  def primary_category
    return categories.min_by(&:position) if categories.loaded?

    categories.order(:position).first
  end

  def to_param
    slug
  end
end
