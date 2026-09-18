# Helpers shared by request specs.
module RequestHelpers
  # The visible text of the last response, tags removed and whitespace
  # collapsed. Money is rendered as nested spans, so a raw body match on
  # "$25.00" would never hit; this asserts on what a person actually reads.
  def page_text
    ActionView::Base.full_sanitizer.sanitize(response.body).squish
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActiveJob::TestHelper, type: :request
end
