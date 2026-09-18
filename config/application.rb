require_relative "boot"

# Middleware is configured while the application is being defined, which is
# before autoloading is set up, so this one is required explicitly instead of
# being autoloaded from lib.
require_relative "../lib/redirect_middleware"

# Middleware is configured while the application is being defined, which is
# before autoloading is set up, so this one is required explicitly instead of
# being autoloaded from lib.
require_relative "../lib/redirect_middleware"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module WellnessToys
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    config.generators do |generators|
      generators.system_tests = nil
      generators.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      generators.factory_bot false
      generators.stylesheets false
      generators.javascripts false
      generators.helper false
    end

    config.action_view.form_with_generates_remote_forms = false

    # Retired URLs are answered before routing, so a slug change is a redirect
    # rather than a 404. See lib/redirect_middleware.rb.
    config.middleware.use RedirectMiddleware

    config.i18n.available_locales = [ :en ]
    config.i18n.default_locale = :en
    config.i18n.raise_on_missing_translations = true
  end
end
