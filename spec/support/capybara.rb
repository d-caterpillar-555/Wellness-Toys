# System specs run through Capybara's rack_test driver: the flows they cover are
# server-rendered, and a real browser would add minutes of runtime without
# covering anything more. The live browser pass is a separate, manual step.
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end
