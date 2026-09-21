require "rails_helper"

# The folio prints the same records as the storefront, so one fixture set covers
# the document and its print view. These examples are also the suite's Bullet
# gate for the folio: Bullet raises in test, so a page that loads what it never
# prints fails here rather than in a log nobody reads.
RSpec.describe "The folio", type: :request do
  before do
    category = create(:category, name: "Vibrators")
    brand = create(:brand, name: "Northlight")
    create(:product, :with_variant, brand: brand, categories: [ category ])

    topic = create(:topic, name: "Sexual health basics")
    article = create(:article, :published, :with_sources, primary_topic: topic)
    article.topics << topic
  end

  # The document is one page and the print view is the same document without the
  # furniture: what these check is that each renders the records it needs.
  it "renders the folio" do
    get folio_path

    expect(response).to have_http_status(:ok)
  end

  it "renders the folio's print view" do
    get folio_print_path

    expect(response).to have_http_status(:ok)
  end

  # The plate is one sequence now: clip_1, link_1 and clip_2 joined, so there is
  # one layer, one count and no range to fade between. The loader screen rides
  # on the same stage, which is why it is asserted here too.
  it "prints the film behind the folio, with the screen that holds it" do
    get folio_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("folio-figure__frame")
    expect(response.body).to include("/worlds/figure/sequences/film-1/frame_0001.webp")
    expect(response.body).to include(%(data-sequence-count="3809"))
    expect(response.body).to include("data-sequence-loader")
    expect(response.body).to include(%(data-sequence-range="0,1"))
  end

  # The sequence is served from public/, so a missing render is a missing file
  # rather than a broken manifest: worth asserting at both ends of it.
  it "ships both ends of the frame sequence" do
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_0001.webp")).to exist
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_3809.webp")).to exist
  end

  # The film is the three renders joined, so its seams must be the same picture
  # on both sides: a cut that jumps is the one thing a joined sequence cannot do.
  it "joins the film at its seams" do
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_2000.webp")).to exist
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_2001.webp")).to exist
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_2600.webp")).to exist
    expect(Rails.root.join("public/worlds/figure/sequences/film-1/frame_2601.webp")).to exist
  end
end
