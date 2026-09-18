Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src :self
    policy.img_src :self, :data
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self
    policy.connect_src :self
    policy.base_uri :none
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # Development runs the policy in report-only mode. Design tooling (the
  # variate card, and anything like it) injects styles the enforcing policy
  # would block; here those violations are reported to the console and nothing
  # is blocked, so the policy still documents itself while the tool stays
  # usable. Production enforces it exactly as written above.
  config.content_security_policy_report_only = true if Rails.env.development?

  # Nonces for the importmap tag and the one inline theme resolver in the
  # layout. No policy allows unsafe-inline for scripts.
  #
  # A per-request random value rather than the session id: the session is not
  # necessarily loaded at the point the nonce is first needed, and an empty
  # nonce silently degrades the policy to 'self' while still emitting
  # nonce="" on every tag. Rails memoises this per request, so the header and
  # every tag within one response see the same value.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
  config.content_security_policy_nonce_auto = true
end
