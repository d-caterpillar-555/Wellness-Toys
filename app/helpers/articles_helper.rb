module ArticlesHelper
  # A pillar is the canonical overview for a topic, so it reads as "Overview"
  # rather than the internal schema name.
  KIND_LABELS = {
    "guide" => "Guide",
    "pillar" => "Overview",
    "glossary" => "Glossary",
    "post" => "Post"
  }.freeze

  # The reading time a card or byline states. Article owns the estimate; the
  # helper only decides how it reads.
  def reading_time(article)
    "#{article.reading_minutes} min read"
  end

  # Author, reading time and date as one line. The separators are decorative,
  # so they are hidden from a screen reader rather than read aloud.
  def article_meta(article)
    parts = [ article.author&.name, reading_time(article), published_date(article) ].compact
    safe_join(parts, tag.span(" / ", class: "text-muted", aria: { hidden: true }))
  end

  # "The Lancet, 2019", or just the publisher when the year is unknown. A
  # missing year is left out, never guessed.
  def source_citation(source)
    source.year ? "#{source.publisher}, #{source.year}" : source.publisher
  end

  # The human word for an article's kind, for a badge or an eyebrow.
  def kind_label(article)
    KIND_LABELS.fetch(article.kind, article.kind.to_s.titleize)
  end

  # Glossary terms keyed by their first letter, for the index and its jump list.
  def grouped_by_initial(articles)
    articles
      .sort_by { |article| article.title.to_s.downcase }
      .group_by { |article| initial_for(article) }
  end

  # A stable anchor for a glossary letter. A term that begins with a non-letter
  # is gathered under "#", which has no slug of its own, so it gets one here.
  def initial_anchor(letter)
    letter == "#" ? "other" : letter.downcase
  end

  # Where an article is reachable. Posts live under /blog; everything else lives
  # under its primary topic. nil when neither is available, so a card can render
  # the same content unlinked rather than as a dead link.
  def article_link_path(article)
    return blog_post_path(article) if article.post?
    return learn_article_path(article.primary_topic, article) if article.primary_topic

    nil
  end

  private
    def published_date(article)
      article.published_at&.to_date&.strftime("%-d %B %Y")
    end

    # A term that does not begin with a letter is gathered under "#", so it
    # still has a home and a jump target on the index.
    def initial_for(article)
      article.title.to_s[/[[:alpha:]]/]&.upcase || "#"
    end
end
