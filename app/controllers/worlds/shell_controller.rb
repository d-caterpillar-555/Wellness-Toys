module Worlds
  # shell: the shop as a machine you talk to.
  #
  # The controller does one thing: it publishes the catalogue, the library and
  # the reference pages as a tree, so the terminal in the browser can resolve
  # real paths. Nothing is invented in JavaScript - every node here is a record,
  # and every object node carries the same specification the object's page does.
  class ShellController < BaseController
    world "shell"

    def index
      @tree = tree
      @objects = shell_catalogue
      @focus = nil
    end

    # A deep link into the machine: the terminal opens with this object already
    # printed, the way a shell can be opened with a command.
    def object
      @product = shell_catalogue.find_by!(slug: params[:slug])
      @tree = tree
      @objects = shell_catalogue
      @focus = @product.slug
      render :index
    end

    private

    # What this world actually prints: the name, the identifier, the price, the
    # specification, the maker and the editions. Not the catalogue relation the
    # other worlds use, which also carries categories and photography.
    def shell_catalogue
      @shell_catalogue ||= policy_scope(Product).available.includes(:brand, :variants).newest_first
    end

    def tree
      {
        name: "/",
        type: "dir",
        children: [ catalogue_node, library_node, *page_nodes ]
      }
    end

    def catalogue_node
      {
        name: "catalogue",
        type: "dir",
        children: departments.map { |category| department_node(category) }
      }
    end

    def department_node(category)
      {
        name: category.slug,
        type: "dir",
        children: shell_catalogue.for_category(category.slug).map { |product| object_node(product) }
      }
    end

    def object_node(product)
      lines = []
      lines << "materials: #{product.materials}" if product.materials.present?
      lines << "body safe: #{product.body_safe? ? 'yes' : 'no'}"
      lines << "dimensions: #{product.dimensions}" if product.dimensions.present?
      lines << "weight: #{product.weight_grams} g" if product.weight_grams.present?
      lines << "maker: #{product.brand.name}" if product.brand

      variants = product.variants.select(&:active?)

      {
        name: product.slug,
        type: "object",
        title: product.name,
        sku: product.sku,
        price: helpers.strip_tags(helpers.price(product.lowest_price_cents)),
        lines: lines,
        description: product.description.to_s,
        variant_id: variants.first&.id,
        variants: variants.map { |variant| { id: variant.id, name: variant.name, price: helpers.strip_tags(helpers.price(variant.price_cents, currency: variant.currency)) } },
        url: shell_object_path(product.slug),
        cart_url: helpers.cart_items_path
      }
    end

    def library_node
      {
        name: "library",
        type: "dir",
        children: policy_scope(Topic).ordered.map do |topic|
          articles = policy_scope(Article).published.kept.where(primary_topic_id: topic.id)

          {
            name: topic.slug,
            type: "dir",
            children: articles.includes(:author).recent_first.map do |article|
              {
                name: article.slug,
                type: "page",
                title: article.title,
                lines: [
                  "kind: #{article.kind}",
                  ("writer: #{article.author.name}" if article.author),
                  ("published: #{article.published_at.strftime('%Y-%m-%d')}" if article.published_at),
                  "sources: #{article.sources_count}"
                ].compact,
                description: article.excerpt.to_s,
                url: helpers.learn_article_path(topic.slug, article.slug)
              }
            end
          }
        end
      }
    end

    def page_nodes
      Page::ROUTED_SLUGS.filter_map do |slug|
        page = page_for(slug)

        if page
          {
            name: slug,
            type: "page",
            title: page.title,
            lines: [ "route: /#{slug}" ],
            description: page.paragraphs.first.to_s,
            url: helpers.page_path(slug)
          }
        else
          {
            name: slug,
            type: "page",
            title: slug.tr("-", " ").capitalize,
            lines: [ "route: /#{slug}" ],
            description: "This page has not been written yet.",
            url: helpers.page_path(slug)
          }
        end
      end
    end
  end
end
