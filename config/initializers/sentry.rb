# Error monitoring. The block does not run at all without a DSN, which is the
# state of development, test, and any deployment that has not opted in.
#
# What is deliberately not sent: breadcrumbs carry identifiers, and what a
# person buys reveals health intent, so personally identifiable information is
# off. Sentry's own request capture is disabled by the same setting.
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = Rails.env
    config.send_default_pii = false
    config.breadcrumbs_logger = [ :active_support_logger ]
    config.traces_sample_rate = 0.1
  end
end
