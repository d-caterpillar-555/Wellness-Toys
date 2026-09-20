require "rails_helper"

# The frame sequences are scrubbed by JavaScript on a real page, so this spec
# drives a real browser: it is the exception to the rack_test rule in
# spec/support/capybara.rb. It exists because the markup and the module once
# disagreed about a selector's name and nothing else noticed - the page simply
# did nothing - and because the same instrument now hangs in two worlds.
RSpec.describe "The scrubbed sequences", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless, screen_size: [ 1440, 900 ]
  end

  it "scrubs the figure's frame sequence as the reader scrolls" do
    visit figure_path

    expect(page).to have_css("[data-sequence-frame='current'][src*='clip-1/frame_0001.webp']")

    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")

    # The playhead eases and the sequence arrives in passes, so what is asserted
    # is that the picture has left the first frame, not the exact frame number.
    expect(page).to have_css("[data-sequence-frame='current']:not([src*='frame_0001.webp'])")
  end

  it "advances the film behind the folio as the reader scrolls the document" do
    visit folio_path

    expect(page).to have_css(".folio-figure [data-sequence-frame='current'][src*='film-1/frame_0001.webp']")

    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")

    expect(page).to have_css(".folio-figure [data-sequence-frame='current']:not([src*='frame_0001.webp'])")
  end

  # The screen that holds the document is shown by script and lifted when every
  # frame is in hand, so the thing to watch is it going away - and the plate
  # being there afterwards.
  it "holds the folio behind the loading screen until the film is loaded" do
    visit folio_path

    expect(page).to have_css("[data-sequence-loader]", visible: :all)
    expect(page).to have_no_css("[data-sequence-loader]:not([hidden])", wait: 60)
    expect(page).to have_css(".is-loaded [data-sequence-loader]", visible: :all)
    expect(page).to have_css(".folio-figure [data-sequence-frame='current']")
  end
end
