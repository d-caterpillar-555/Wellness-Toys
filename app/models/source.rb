class Source < ApplicationRecord
  # The counter cache for articles.sources_count. Rails reads it from this side
  # of the association: the column is named after the model, so `true` resolves
  # to sources_count without repeating the name.
  belongs_to :article, inverse_of: :sources, counter_cache: true

  validates :title, :url, :publisher, presence: true
  validates :url,
    format: { with: %r{\Ahttps?://[^\s]+\z}, message: "must be an http:// or https:// URL" }

  scope :ordered, -> { order(:position) }

  def year
    published_on&.year
  end

  # The evidence rail renders one string per citation: "The Lancet, 2019".
  def display_publisher
    if year
      "#{publisher}, #{year}"
    else
      publisher
    end
  end

  # A malformed URL must not break the evidence rail, so an unparseable citation
  # loses only its host link rather than raising mid-render.
  def host
    URI.parse(url).host
  rescue URI::InvalidURIError
    nil
  end
end
