class Page < ApplicationRecord
  include Discard::Model

  # The pages that have a route. This list is the single owner of that fact:
  # routes are drawn from it and the sitemap is built from it, so a page can
  # never be routable but unlisted, or listed but unroutable.
  ROUTED_SLUGS = %w[
    about standards contact shipping returns privacy terms accessibility
    discreet-shipping faq
  ].freeze

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true

  scope :published, -> { where(published_at: ..Time.current) }
  scope :listed, -> { published.kept.ordered }
  scope :ordered, -> { order(:position, :title) }

  def self.find_by_slug!(slug)
    published.kept.find_by!(slug: slug)
  end

  # The body is stored as plain text and split into paragraphs on blank lines.
  # Deliberately not rich text: a page that an editor can only change through a
  # constrained set of paragraphs cannot accidentally publish raw markup.
  def paragraphs
    body.to_s.split(/\n{2,}/).map(&:strip).reject(&:empty?)
  end
end
