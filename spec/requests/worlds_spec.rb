require "rails_helper"

# Every world renders the same records, so one fixture set covers all eight.
# These examples are also the suite's Bullet gate for the worlds: Bullet raises
# in test, so a page that loads what it never prints fails here rather than in
# a log nobody reads.
RSpec.describe "Worlds", type: :request do
  before do
    category = create(:category, name: "Vibrators")
    brand = create(:brand, name: "Northlight")
    create(:product, :with_variant, brand: brand, categories: [ category ])

    topic = create(:topic, name: "Sexual health basics")
    article = create(:article, :published, :with_sources, primary_topic: topic)
    article.topics << topic
  end

  # One example per page: a world is a page inventory, and what these check is
  # that each page renders the records it needs and no more.
  {
    "the folio" => -> { folio_path },
    "the folio's print view" => -> { folio_print_path },
    "the figure" => -> { figure_path },
    "the figure's catalogue" => -> { figure_pieces_path },
    "a piece of the figure" => -> { figure_piece_path(Product.first.slug) },
    "the plan" => -> { plan_path },
    "the register" => -> { plan_register_path },
    "a room on the plan" => -> { plan_room_path(Category.first.slug) },
    "an object on the plan" => -> { plan_object_path(Product.first.slug) },
    "the shell" => -> { shell_path },
    "an object in the shell" => -> { shell_object_path(Product.first.slug) },
    "the press front page" => -> { press_path },
    "the press review section" => -> { press_catalogue_path },
    "the press issue" => -> { press_issue_path },
    "a story reprinted in the press" => -> { press_story_path(Topic.first.slug, Article.first.slug) },
    "the press notices" => -> { press_notices_path },
    "the desk" => -> { desk_path },
    "the desk shelf" => -> { desk_shelf_path },
    "an item brought to the desk" => -> { desk_item_path(Product.first.slug) },
    "the deck" => -> { deck_path },
    "the deck's library" => -> { deck_library_path },
    "the deck's policies" => -> { deck_policies_path },
    "a record in the deck" => -> { deck_item_path(Product.first.slug) }
  }.each do |name, path|
    it "renders #{name}" do
      get instance_exec(&path)

      expect(response).to have_http_status(:ok)
    end
  end

  it "renders the figure with its frame sequence" do
    get figure_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("fig-figure__frame")
    expect(response.body).to include("/worlds/figure/sequences/kiss/frame_0001.webp")
    expect(response.body).to include(%(data-sequence-count="2000"))
    expect(response.body).to include(%(data-sequence-frame="current"))
  end

  it "prints clip one behind the folio" do
    get folio_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("folio-figure__frame")
    expect(response.body).to include("/worlds/figure/sequences/kiss/frame_0001.webp")
    expect(response.body).to include(%(data-sequence-range="0,1"))
  end

  # The sequence is served from public/, so a missing render is a missing file
  # rather than a broken manifest: worth asserting at both ends of it.
  it "ships both ends of the figure's frame sequence" do
    expect(Rails.root.join("public/worlds/figure/sequences/kiss/frame_0001.webp")).to exist
    expect(Rails.root.join("public/worlds/figure/sequences/kiss/frame_2000.webp")).to exist
  end
end
