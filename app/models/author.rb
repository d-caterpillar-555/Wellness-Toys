class Author < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  has_many :articles, dependent: :nullify

  validates :slug, presence: true, uniqueness: true

  scope :kept_active, -> { kept }
  scope :ordered, -> { order(:position, :name) }
  scope :clinicians, -> { where(is_clinician: true) }
  scope :with_published_articles, -> { kept.joins(:articles).merge(Article.published).distinct }

  # One query for every kept author's published-article count, so the experts
  # index sizes its badges without a count per row. The LEFT JOIN keeps an
  # author who has published nothing yet rather than dropping them silently.
  scope :with_published_article_count, -> {
    joins(
      "LEFT JOIN articles counted_articles ON counted_articles.author_id = authors.id " \
      "AND counted_articles.status = 'published' AND counted_articles.published_at <= NOW() " \
      "AND counted_articles.discarded_at IS NULL"
    )
    .group("authors.id")
    .select("authors.*", "COUNT(counted_articles.id) AS published_article_count")
  }

  def published_articles
    articles.published.recent_first
  end

  def published_article_count
    self[:published_article_count] || published_articles.kept.count
  end

  # Credentials are the author's own words about their qualifications. If the
  # column is blank it stays blank: a fabricated one is worse than a missing
  # one, so this never invents or defaults a value.
  def has_credentials?
    credentials.present?
  end

  def to_param
    slug
  end
end
