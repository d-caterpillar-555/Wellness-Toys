# Sign-in. Rate limited with Rails' own limiter, so credential stuffing costs
# the attacker something: ten attempts per IP in three minutes, well above what
# a person typing their own password ever needs.
class Users::SessionsController < Devise::SessionsController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_user_session_path, alert: t("auth.rate_limited") }

  protected
    def after_sign_in_path_for(resource)
      stored_location_for(resource) || account_root_path
    end

    def after_sign_out_path_for(resource_or_scope)
      root_path
    end
end
