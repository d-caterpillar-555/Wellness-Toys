class Article < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  KINDS = %w[guide pillar glossary post].freeze
  STATUSES = %w[draft published archived].freeze

  belongs_to :author, optional: true
  belongs_to :primary_topic, class_name: "Topic", optional: true
  has_many :article_topics, dependent: :destroy
  has_many :topics, through: :article_topics
  has_many :sources, -> { order(:position) }, dependent: :destroy, inverse_of: :article

  has_one_attached :hero_image

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :excerpt, length: { maximum: 300 }, allow_blank: true
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }

  scope :guides, -> { where(kind: "guide") }
  scope :pillars, -> { where(kind: "pillar") }
  scope :glossary_terms, -> { where(kind: "glossary") }
  scope :posts, -> { where(kind: "post") }

  # Published is both approved and dated no later than now, so a scheduled
  # article is simply one whose time has not come yet.
  scope :published, -> { where(status: "published").where(published_at: ..Time.current) }
  scope :draft, -> { where(status: "draft") }
  scope :archived, -> { where(status: "archived") }

  scope :kept_visible, -> { kept }
  scope :recent_first, -> { order(published_at: :desc, created_at: :desc) }
  scope :alphabetical, -> { order(:title) }

  # Title match for the shop's search results. The education side has its own
  # relevance column later; this is the same ILIKE fallback Product uses.
  scope :search_by_title, ->(query) {
    where("title ILIKE :q", q: "%#{Article.sanitize_sql_like(query.to_s)}%")
  }
  # The byline and the topic, for a card or a list. Sources are included
  # separately: only the page that renders the evidence rail needs them, and
  # loading them into every list view is a query nothing there uses.
  scope :with_reading_list, -> { includes(:author, :primary_topic) }
  scope :with_evidence, -> { includes(:sources) }

  def guide?
    kind == "guide"
  end

  def pillar?
    kind == "pillar"
  end

  def glossary?
    kind == "glossary"
  end

  def post?
    kind == "post"
  end

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end

  def archived?
    status == "archived"
  end

  # reading_minutes is nullable so an editor can pin an exact value. When it is
  # blank we estimate from the body at a conventional 200 words per minute.
  def reading_minutes
    super || [ (body.to_s.split.size / 200.0).ceil, 1 ].max
  end

  def reading_time_label
    "#{reading_minutes} min read"
  end

  def evidence?
    sources.any?
  end

  def to_param
    slug
  end

  # The body is plain text split into paragraphs on blank lines, the same shape
  # a Page body has. Deliberately not rich text: a constrained paragraph set
  # cannot publish raw markup by accident.
  def paragraphs
    body.to_s.split(/\n{2,}/).map(&:strip).reject(&:empty?)
  end
end
