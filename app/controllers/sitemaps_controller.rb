# Every published URL, for crawlers.
#
# Built from the same scopes the pages use, so something a visitor cannot reach
# cannot end up here either: no draft products, no unpublished articles, nothing
# under an account, a cart, a checkout or the console.
#
# Locations are absolute and use Store.url rather than the request host: the
# sitemap states the canonical host on purpose, whichever host asked for it.
class SitemapsController < ApplicationController
  def show
    authorize :sitemap, :show?
    @entries = entries
    expires_in 1.hour, public: true
  end

  private
    def entries
      [ home_entry, shop_entry ] + collection_entries + category_entries +
        product_entries + education_entries + page_entries
    end

    def home_entry
      { loc: Store.url, changefreq: "daily", priority: "1.0" }
    end

    def shop_entry
      { loc: "#{Store.url}#{shop_path}", changefreq: "daily", priority: "0.9" }
    end

    def collection_entries
      CollectionsController::COLLECTIONS.keys.map do |slug|
        { loc: "#{Store.url}#{collection_path(slug)}", changefreq: "weekly", priority: "0.6" }
      end
    end

    def category_entries
      Category.kept.ordered.map do |category|
        { loc: "#{Store.url}#{category_path(category)}", lastmod: category.updated_at, changefreq: "weekly", priority: "0.8" }
      end
    end

    # Deliberately not with_catalogue: the sitemap needs a URL and a date, so it
    # loads only the categories the URL is built from.
    def product_entries
      Product.available.newest_first.includes(:categories).map do |product|
        { loc: "#{Store.url}#{product_path(product.primary_category, product)}", lastmod: product.updated_at, changefreq: "weekly", priority: "0.8" }
      end
    end

    def education_entries
      topic_entries + article_entries + author_entries + glossary_entries + blog_entries
    end

    def topic_entries
      Topic.kept.ordered.map do |topic|
        { loc: "#{Store.url}#{learn_topic_path(topic)}", lastmod: topic.updated_at, changefreq: "weekly", priority: "0.7" }
      end
    end

    def article_entries
      Article.published.kept.includes(:primary_topic).filter_map do |article|
        next if article.post? || article.primary_topic.nil?

        { loc: "#{Store.url}#{learn_article_path(article.primary_topic, article)}", lastmod: article.updated_at, changefreq: "monthly", priority: "0.7" }
      end
    end

    def author_entries
      Author.kept_active.ordered.map do |author|
        { loc: "#{Store.url}#{learn_expert_path(author)}", lastmod: author.updated_at, changefreq: "monthly", priority: "0.5" }
      end
    end

    def glossary_entries
      Article.published.glossary_terms.kept.alphabetical.map do |term|
        { loc: "#{Store.url}#{learn_glossary_term_path(term)}", lastmod: term.updated_at, changefreq: "monthly", priority: "0.5" }
      end
    end

    def blog_entries
      posts = Article.published.posts.kept.recent_first
      return [] if posts.empty?

      [ { loc: "#{Store.url}#{blog_path}", changefreq: "weekly", priority: "0.6" } ] +
        posts.map { |post| { loc: "#{Store.url}#{blog_post_path(post)}", lastmod: post.updated_at, changefreq: "monthly", priority: "0.6" } }
    end

    # Only pages that have a route. The list of routed slugs lives on the model
    # so a page can never be routable but unlisted, or listed but unroutable.
    def page_entries
      Page.published.kept.where(slug: Page::ROUTED_SLUGS).map do |page|
        helper = :"page_#{page.slug.tr('-', '_')}_path"
        next unless respond_to?(helper, true)

        { loc: "#{Store.url}#{public_send(helper)}", lastmod: page.updated_at, changefreq: "yearly", priority: "0.4" }
      end.compact
    end
end
