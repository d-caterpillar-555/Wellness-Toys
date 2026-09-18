# The eight architectures. See docs/eight-worlds.md for what each one is.
#
# A world is not a colourway: it is an architecture - its own page inventory,
# navigation model, layout, stylesheet and JavaScript. This registry is the one
# place that lists them. The dock, the gallery page and script/check-contrast
# all read it, so the list cannot drift.
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
    ),
    new(
      slug: "figure",
      name: "Figure",
      tagline: "The scroll choreography",
      prefix: "figure",
      premise: "A drawn figure changes pose as you scroll; the copy and the catalogue arrive with each pose."
    ),
    new(
      slug: "plan",
      name: "Plan",
      tagline: "The shop as a building",
      prefix: "plan",
      premise: "Departments are rooms on a floor plan. You navigate by walking into them."
    ),
    new(
      slug: "shell",
      name: "Shell",
      tagline: "The shop as a command line",
      prefix: "shell",
      premise: "A prompt and a filesystem: the catalogue, the library and the cart, all reachable by typing."
    ),
    new(
      slug: "press",
      name: "Press",
      tagline: "The shop as a newspaper",
      prefix: "press",
      premise: "A paper that reviews what it sells, set in columns, with notices where the advertising would be."
    ),
    new(
      slug: "desk",
      name: "Desk",
      tagline: "The shop as a conversation",
      prefix: "desk",
      premise: "A concierge asks what you need and brings things to the desk, one answer at a time."
    ),
    new(
      slug: "deck",
      name: "Deck",
      tagline: "The shop as a control room",
      prefix: "deck",
      premise: "A dense, keyboard-driven console for the catalogue, with the library and the policies alongside."
    )
  ].freeze

  def self.all
    ALL
  end

  def self.find(slug)
    ALL.find { |world| world.slug == slug.to_s }
  end

  def self.fetch(slug)
    find(slug) || raise(ActiveRecord::RecordNotFound, "no world named #{slug.inspect}")
  end

  def self.slugs
    ALL.map(&:slug)
  end

  # Institute is the default architecture and owns the canonical routes.
  def canonical?
    prefix.nil?
  end

  def home_path
    canonical? ? "/" : "/#{prefix}"
  end

  def layout
    canonical? ? "application" : "worlds/#{slug}"
  end

  def stylesheet
    "worlds/#{slug}"
  end

  def current?(request)
    return false if request.nil?

    if canonical?
      ALL.none? { |world| world.prefix && request.path.start_with?("/#{world.prefix}") }
    else
      request.path == "/#{prefix}" || request.path.start_with?("/#{prefix}/")
    end
  end
end
