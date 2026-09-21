# The architectures the site publishes. See docs/folio-world.md.
#
# A world is not a colourway: it is an architecture - its own page inventory,
# navigation model, layout, stylesheet and JavaScript. Institute is the store's
# own chrome and owns the canonical routes; the folio is the one alternate
# architecture still published.
#
# The registry exists so a world controller names its world once and gets its
# layout from that name, rather than repeating a layout string per controller.
class World
  attr_reader :slug, :name, :tagline, :premise, :prefix

  def initialize(slug:, name:, tagline:, premise:, prefix: nil)
    @slug = slug
    @name = name
    @tagline = tagline
    @premise = premise
    @prefix = prefix
  end

  ALL = [
    new(
      slug: "institute",
      name: "Institute",
      tagline: "The annual report",
      premise: "Every page is a numbered section of one publication, with a contents rail and a running head."
    ),
    new(
      slug: "folio",
      name: "Folio",
      tagline: "Everything on one page",
      prefix: "folio",
      premise: "The whole shop as one continuous document, read top to bottom, with an index that never leaves the screen."
    )
  ].freeze

  def self.find(slug)
    ALL.find { |world| world.slug == slug.to_s }
  end

  def self.fetch(slug)
    find(slug) || raise(ActiveRecord::RecordNotFound, "no world named #{slug.inspect}")
  end

  # Institute is the store's own architecture and owns the canonical routes.
  def canonical?
    prefix.nil?
  end

  def layout
    canonical? ? "application" : "worlds/#{slug}"
  end
end
