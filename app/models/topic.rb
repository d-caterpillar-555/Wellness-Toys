class Topic < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :parent, class_name: "Topic", optional: true
  has_many :children,
    class_name: "Topic",
    foreign_key: :parent_id,
    inverse_of: :parent,
    dependent: :nullify

  has_many :article_topics, dependent: :destroy
  has_many :articles, through: :article_topics

  scope :roots, -> { kept.where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  scope :published, -> { kept.joins(:articles).merge(Article.published).distinct }

  def root?
    parent_id.nil?
  end

  def published_articles
    articles.published
  end

  # Published-article counts for an index page, computed in one query so listing
  # five topics does not fire five counts. The LEFT JOINs keep a topic that has
  # published nothing, which is a real state and should not vanish from /learn.
  scope :with_published_article_count, -> {
    joins("LEFT JOIN article_topics counted_article_topics ON counted_article_topics.topic_id = topics.id")
      .joins(
        "LEFT JOIN articles counted_articles ON counted_articles.id = counted_article_topics.article_id " \
        "AND counted_articles.status = 'published' AND counted_articles.published_at <= NOW() " \
        "AND counted_articles.discarded_at IS NULL"
      )
      .group("topics.id")
      .select("topics.*", "COUNT(counted_articles.id) AS published_article_count")
  }

  def published_article_count
    self[:published_article_count] || published_articles.kept.count
  end

  def to_param
    slug
  end
end
