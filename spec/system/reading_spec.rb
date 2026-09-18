require "rails_helper"

RSpec.describe "Reading the library", type: :system do
  it "shows an article and the evidence behind it" do
    author = create(:author, name: "Rae Lindqvist", credentials: "Registered nurse, twelve years")
    topic = create(:topic, name: "Communication")
    article = create(:article, :published, :guide, title: "Talking plainly", author: author, primary_topic: topic)
    article.topics << topic
    create(:source, article: article, title: "A study of conversations", publisher: "The Lancet", published_on: Date.new(2019, 4, 1))

    visit learn_path
    click_link "Talking plainly"

    expect(page).to have_text("Talking plainly")
    expect(page).to have_text("Rae Lindqvist")
    expect(page).to have_text("Sources")
    expect(page).to have_text("The Lancet, 2019")
  end
end
