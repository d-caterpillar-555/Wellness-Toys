class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Provides the `pagy(:offset, collection, ...)` helper to every controller.
  # Pagy owns page counting; the views own how the links look.
  include Pagy::Method

  # Every page renders the header cart count, so cart resolution belongs on the
  # base controller rather than only on the commerce controllers.
  include CartScoped

  allow_browser versions: :modern

  stale_when_importmap_changes

  # Default deny, enforced per action rather than by convention: index actions
  # have to resolve a policy scope, and every other action has to authorise a
  # record or a policy symbol. A controller with nothing to authorise says so
  # with an explicit skip_authorization, which is a deliberate line rather than
  # an omission.
  #
  # Declared as conditions rather than :only options: this application raises on
  # callback options that name an action the controller does not have, and most
  # controllers here have no index action at all.
  after_action :verify_authorized, unless: -> { action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  helper_method :age_confirmed?, :consent_decided?

  private
    def render_forbidden
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "You are not allowed to do that." }
        format.any { head :forbidden }
      end
    end

    # The age gate is soft: the answer lives in the session and every page can
    # ask. Nothing else reads it.
    def age_confirmed?
      session[:age_confirmed_at].present?
    end

    # Consent belongs to a subject: the account for a signed-in person (see
    # Account::ConsentsController), the browser session for a guest. Deriving it
    # in one place is what keeps the public banner and the account page from
    # recording under two different identities.
    def consent_subject_token
      if user_signed_in?
        "user-#{current_user.id}"
      else
        session[:consent_subject_token] ||= SecureRandom.urlsafe_base64(24)
      end
    end

    # Memoised: the layout asks once per request, and the banner is the only
    # thing that needs the answer.
    def consent_decided?
      return @consent_decided if defined?(@consent_decided)

      @consent_decided = ConsentRecord.where(subject_token: consent_subject_token).exists?
    end
end
