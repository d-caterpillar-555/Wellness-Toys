# Structured data for the public pages, as JSON-LD.
#
# Server-rendered on purpose. Google documents that structured data injected by
# JavaScript may be processed late or missed, and Product/Offer markup is the
# kind that matters most to a shop.
#
# Only facts the page itself states are emitted: no invented ratings, no
# fabricated review counts, no shipping rates the store has not set. A product
# with no photograph simply has no image property rather than a stand-in.
module StructuredDataHelper
  # Google requires consent-relevant adult listings to say so. The value is the
  # only one Google supports.
  ADULT_CONSIDERATION = "https://schema.org/SexualContentConsideration".freeze

  # The tag itself. `nonce` is passed explicitly: the CSP for this site allows
  # no inline script without one, and a JSON-LD block is still a script element.
  #
  # json_escape neutralises the characters that could end the element early
  # (a product name containing "</script>", for instance), which is why the
  # result can be marked safe: tag.script would otherwise escape every quote
  # into an entity, and browsers do not decode entities inside a script element.
  def json_ld(data)
    tag.script(
      json_escape(JSON.generate(data)).html_safe,
      type: "application/ld+json",
      nonce: content_security_policy_nonce
    )
  end

  # Every page carries the publisher and the site, so a page-level graph can
  # refer to them by @id instead of restating them.
  def organization_schema
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "@id" => "#{Store.url}/#organization",
      "name" => Store.name,
      "url" => Store.url,
      "description" => Store.tagline,
      "email" => Store.support_email
    }
  end

  def website_schema
    {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "@id" => "#{Store.url}/#website",
      "name" => Store.name,
      "url" => Store.url,
      "publisher" => { "@id" => "#{Store.url}/#organization" },
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => {
          "@type" => "EntryPoint",
          "urlTemplate" => "#{Store.url}/search?q={search_term_string}"
        },
        "query-input" => "required name=search_term_string"
      }
    }
  end

  # trail is an array of [name, path] pairs, in order.
  def breadcrumb_schema(trail)
    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => trail.each_with_index.map { |(name, path), index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => name,
          "item" => "#{Store.url}#{path}"
        }
      }
    }
  end

  def product_schema(product, variants:, category: nil)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Product",
      "name" => product.name,
      "url" => "#{Store.url}#{product_path_for(product, category)}",
      "sku" => product.sku,
      "hasAdultConsideration" => ADULT_CONSIDERATION,
      "offers" => variants.map { |variant| offer_schema(product, variant, category) }
    }

    schema["description"] = product.description.presence || product.subtitle.presence
    schema["brand"] = { "@type" => "Brand", "name" => product.brand.name } if product.brand
    schema["category"] = category.name if category
    schema["image"] = [ "#{Store.url}#{url_for(product.cover_image)}" ] if product.cover_image.attached?

    schema.compact
  end

  def article_schema(article)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => article.title,
      "url" => "#{Store.url}#{article_path_for(article)}",
      "datePublished" => article.published_at&.iso8601,
      "dateModified" => article.updated_at.iso8601,
      "inLanguage" => "en",
      "publisher" => { "@id" => "#{Store.url}/#organization" },
      "author" => article.author ? person_schema(article.author) : nil
    }

    schema["description"] = article.excerpt.presence
    schema["articleSection"] = article.primary_topic.name if article.primary_topic
    schema["image"] = [ "#{Store.url}#{url_for(article.hero_image)}" ] if article.hero_image.attached?

    schema.compact
  end

  # A writer, as the page presents them. The credentials are the writer's own
  # words and go in the description; they are never restated as a certification
  # claim, which is a different and stronger assertion.
  def person_schema(author)
    {
      "@type" => "Person",
      "name" => author.name,
      "url" => "#{Store.url}#{learn_expert_path(author)}",
      "description" => [ author.bio, author.credentials ].compact_blank.join(" ")
    }.compact
  end

  private
    def offer_schema(product, variant, category)
      {
        "@type" => "Offer",
        "url" => "#{Store.url}#{product_path_for(product, category)}",
        "price" => format("%.2f", variant.price_cents / 100.0),
        "priceCurrency" => variant.currency,
        "availability" => variant.in_stock? ? "https://schema.org/InStock" : "https://schema.org/OutOfStock",
        "itemCondition" => "https://schema.org/NewCondition",
        "sku" => variant.sku,
        "seller" => { "@id" => "#{Store.url}/#organization" }
      }
    end

    def product_path_for(product, category)
      product_path(category || product.primary_category || product.categories.kept.first, product)
    end

    # An article lives under its topic when it has one, and under the blog when
    # it is a post. A piece with neither has no public path and is not marked up.
    def article_path_for(article)
      if article.post?
        blog_post_path(article)
      else
        learn_article_path(article.primary_topic, article)
      end
    end
end
