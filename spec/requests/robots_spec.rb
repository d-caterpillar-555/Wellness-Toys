require "rails_helper"

RSpec.describe "Robots", type: :request do
  it "serves plain text" do
    get robots_path

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/plain")
  end

  it "keeps crawlers out of sessions, carts, checkouts and the console" do
    get robots_path

    expect(response.body).to include("Disallow: /account")
    expect(response.body).to include("Disallow: /cart")
    expect(response.body).to include("Disallow: /checkout")
    expect(response.body).to include("Disallow: /orders")
    expect(response.body).to include("Disallow: /admin")
    expect(response.body).to include("Disallow: /search")
  end

  it "points at the sitemap" do
    get robots_path

    expect(response.body).to include("Sitemap: #{Store.url}/sitemap.xml")
  end
end
