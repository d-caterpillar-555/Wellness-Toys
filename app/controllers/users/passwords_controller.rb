# Password reset. Devise owns the logic; this subclass exists so the reset pages
# live with the rest of the account surfaces, and so the request endpoint is
# rate limited like the other authentication endpoints.
class Users::PasswordsController < Devise::PasswordsController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  rate_limit to: 5, within: 15.minutes, only: :create,
    with: -> { redirect_to new_user_password_path, alert: t("auth.rate_limited") }
end
