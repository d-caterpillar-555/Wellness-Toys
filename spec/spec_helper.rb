# Coverage is measured for the whole suite. See
# https://github.com/simplecov-ruby/simplecov for the options.
require "simplecov"

SimpleCov.start "rails" do
  skip "spec/"
  skip "config/"
  skip "db/"
  skip "app/avo/"
end

# The floor applies to a full run. `rspec spec/system` covers a fraction of the
# app by definition, and failing it for that would make the floor something
# people learn to switch off.
SimpleCov.minimum_coverage 88 if RSpec.configuration.files_to_run.size > 20

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Random order, with the seed reported on failure, so no spec can come to
  # depend on running after another one.
  config.order = :random
  Kernel.srand config.seed
end
