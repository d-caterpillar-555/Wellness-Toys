require "rails_helper"

# Structured data is server-rendered in the HTML, per Google's own guidance:
# markup that only appears after JavaScript runs may be processed late or missed.
RSpec.describe "Structured data", type: :request do
  def json_ld_blocks
    Nokogiri::HTML(response.body)
      .css('script[type="application/ld+json"]')
      .map { |node| JSON.parse(node.text) }
  end

  def types
    json_ld_blocks.map { |block| block["@type"] }
  end

  it "publishes the publisher and the site on every page" do
    get root_path

    expect(types).to include("Organization", "WebSite")

    website = json_ld_blocks.find { |block| block["@type"] == "WebSite" }
    expect(website.dig("potentialAction", "@type")).to eq("SearchAction")
    expect(website.dig("potentialAction", "target", "urlTemplate")).to eq("#{Store.url}/search?q={search_term_string}")
  end

  it "signs every block with the request nonce, because the CSP allows no inline script without one" do
    get root_path

    scripts = Nokogiri::HTML(response.body).css('script[type="application/ld+json"]')

    expect(scripts).to be_present
    expect(scripts.map { |script| script["nonce"] }).to all(be_present)
  end

  it "marks up a product with its offers and the adult consideration Google requires" do
    category = create(:category, name: "Lubricants")
    product = create(:product, :with_variant, name: "Water Based Lubricant", sku: "WT-LUBE-1")
    product.categories << category
    variant = product.variants.first

    get product_path(category, product)

    block = json_ld_blocks.find { |entry| entry["@type"] == "Product" }
    expect(block["name"]).to eq("Water Based Lubricant")
    expect(block["sku"]).to eq("WT-LUBE-1")
    expect(block["hasAdultConsideration"]).to eq("https://schema.org/SexualContentConsideration")

    offer = block["offers"].first
    expect(offer["price"]).to eq(format("%.2f", variant.price_cents / 100.0))
    expect(offer["priceCurrency"]).to eq("USD")
    expect(offer["availability"]).to eq("https://schema.org/InStock")
    expect(offer["itemCondition"]).to eq("https://schema.org/NewCondition")
  end

  it "states a sold-out configuration as sold out rather than leaving it out" do
    category = create(:category)
    product = create(:product, :with_variant)
    product.categories << category
    product.variants.first.update!(stock_quantity: 0)

    get product_path(category, product)

    block = json_ld_blocks.find { |entry| entry["@type"] == "Product" }
    expect(block["offers"].first["availability"]).to eq("https://schema.org/OutOfStock")
  end

  it "does not build FAQ rich results, which Google retired" do
    category = create(:category)
    product = create(:product, :with_variant)
    product.categories << category

    get product_path(category, product)

    expect(types).not_to include("FAQPage", "HowTo")
  end

  it "carries a breadcrumb trail on a product page" do
    category = create(:category, name: "Massage")
    product = create(:product, :with_variant, name: "Massage Oil")
    product.categories << category

    get product_path(category, product)

    breadcrumb = json_ld_blocks.find { |entry| entry["@type"] == "BreadcrumbList" }
    expect(breadcrumb["itemListElement"].map { |item| item["name"] }).to eq([ "Shop", "Massage", "Massage Oil" ])
  end

  it "marks up an article with its writer and publication date" do
    author = create(:author, name: "Rae Lindqvist")
    topic = create(:topic, name: "Communication")
    article = create(:article, :published, :guide, title: "Talking plainly", author: author, primary_topic: topic)
    article.topics << topic

    get learn_article_path(topic, article)

    block = json_ld_blocks.find { |entry| entry["@type"] == "Article" }
    expect(block["headline"]).to eq("Talking plainly")
    expect(block["datePublished"]).to eq(article.published_at.iso8601)
    expect(block.dig("author", "name")).to eq("Rae Lindqvist")
    expect(block["articleSection"]).to eq("Communication")
  end

  it "marks up a writer as a person, in their own words" do
    author = create(:author, name: "Rae Lindqvist", bio: "DEMO. Writes about communication.", credentials: "Registered nurse, twelve years")

    get learn_expert_path(author)

    block = json_ld_blocks.find { |entry| entry["@type"] == "Person" }
    expect(block["name"]).to eq("Rae Lindqvist")
    expect(block["description"]).to include("Registered nurse, twelve years")
    expect(block["url"]).to eq("#{Store.url}#{learn_expert_path(author)}")
  end
end
