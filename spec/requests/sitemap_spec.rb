require "rails_helper"

RSpec.describe "Sitemap", type: :request do
  it "serves XML at the canonical host" do
    get sitemap_path

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/xml")
    expect(response.body).to include("<urlset")
    expect(response.body).to include("#{Store.url}#{shop_path}")
  end

  it "lists published products under their category" do
    category = create(:category, name: "Massage")
    product = create(:product, :with_variant, name: "Massage Oil")
    product.categories << category

    get sitemap_path

    expect(response.body).to include("#{Store.url}#{product_path(category, product)}")
  end

  it "leaves drafts out" do
    category = create(:category)
    draft = create(:product, status: "draft", published_at: nil)
    draft.categories << category

    get sitemap_path

    expect(response.body).not_to include(draft.slug)
  end

  it "lists published articles but not drafts" do
    topic = create(:topic)
    published = create(:article, :published, :guide, title: "A published guide", primary_topic: topic)
    draft = create(:article, title: "An unpublished guide", primary_topic: topic)

    get sitemap_path

    expect(response.body).to include(learn_article_path(topic, published))
    expect(response.body).not_to include(draft.slug)
  end

  it "lists only the pages that have a route" do
    # The seeded database already carries the routed pages, so this asserts the
    # two halves separately: a routed page is listed, an unrouted one is not.
    Page.create!(slug: "not-routed-anywhere", title: "Elsewhere", body: "Text", published_at: 1.day.ago)
    routed = Page.find_or_create_by!(slug: "about") do |page|
      page.title = "About"
      page.body = "Text"
    end
    routed.update!(published_at: 1.day.ago)

    get sitemap_path

    expect(response.body).to include(page_about_path)
    expect(response.body).not_to include("not-routed-anywhere")
  end

  it "keeps accounts, carts, checkouts and the console out of it" do
    get sitemap_path

    expect(response.body).not_to include("/account")
    expect(response.body).not_to include("/cart")
    expect(response.body).not_to include("/checkout")
    expect(response.body).not_to include("/orders")
    expect(response.body).not_to include("/admin")
  end
end
