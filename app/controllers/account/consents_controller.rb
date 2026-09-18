# The consent decisions attached to this account.
#
# Consent records are append-only: granting writes a row, and withdrawing writes
# a second row referring to the first. Nothing is ever edited or deleted, so the
# history of what was agreed, and when, survives a change of mind.
#
# A signed-in person's consent belongs to the account rather than to the browser
# session, so it is the same record on every device. A guest's consent is keyed
# to the session token instead (see the public consent controller).
class Account::ConsentsController < Account::BaseController
  def show
    authorize ConsentRecord, :index?
    @consents = ConsentRecord.current_for(subject_token: subject_token)
    @records = policy_scope(ConsentRecord).chronological.group_by(&:kind).transform_values(&:last)
  end

  def update
    authorize ConsentRecord, :update?
    ConsentRecord::KINDS.each { |kind| record_decision(kind) }
    redirect_to account_consent_path, notice: t("account.consent.updated")
  end

  private
    def record_decision(kind)
      granted = params.dig(:consent, kind) == "1"
      return if granted == ConsentRecord.granted?(subject_token: subject_token, kind: kind)

      if granted
        ConsentRecord.grant(subject_token: subject_token, kind: kind, policy_version: Store.policy_version, user: current_user)
      else
        ConsentRecord.withdraw(subject_token: subject_token, kind: kind, policy_version: Store.policy_version, user: current_user)
      end
    end

    def subject_token
      "user-#{current_user.id}"
    end
end
