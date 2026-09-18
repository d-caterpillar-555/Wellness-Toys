# Sign-up. The form asks two questions that the database stores as timestamps:
# confirmation of legal age, and acceptance of the terms. The timestamps are the
# record; the checkboxes are only how the question is asked, so an unchecked box
# leaves the timestamp nil and the model's validations refuse the account.
class Users::RegistrationsController < Devise::RegistrationsController
  # Registration is a person acting on their own account, so there is no record
  # a third party could be granted access to. The skips are explicit so the
  # absence of an authorize call is a decision rather than an omission.
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  protected
    def sign_up_params
      params.require(:user).permit(
        :name, :email, :phone, :password, :password_confirmation,
        :age_confirmed, :terms_accepted
      )
    end

    def account_update_params
      params.require(:user).permit(
        :name, :phone, :email, :password, :password_confirmation, :current_password
      )
    end

    # The confirmation flags are not columns, so they are removed before the
    # record is built and turned into timestamps instead.
    def build_resource(hash = {})
      super(hash.except(:age_confirmed, :terms_accepted))
      resource.age_confirmed_at = Time.current if checked?(:age_confirmed)
      resource.terms_accepted_at = Time.current if checked?(:terms_accepted)
    end

    def checked?(field)
      params.dig(:user, field) == "1"
    end

    def after_sign_up_path_for(resource)
      account_root_path
    end

    def after_update_path_for(resource)
      account_profile_path
    end
end
