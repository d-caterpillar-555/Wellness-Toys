# Consent for a visitor without an account, keyed to a token in their session.
# A signed-in person records theirs on the account page instead, where the
# subject is the account rather than the browser.
#
# Nothing here switches a tracker on: the store ships none. What it records is
# the answer, so a consented layer could be added later without inventing a
# history that never happened.
class ConsentController < ApplicationController
  def create
    authorize ConsentRecord, :create?
    ConsentRecord::KINDS.each { |kind| record_decision(kind) }
    redirect_back fallback_location: root_path, notice: t("consent.saved")
  end

  def withdraw
    authorize ConsentRecord, :create?
    ConsentRecord::KINDS.each do |kind|
      next unless ConsentRecord.granted?(subject_token: consent_subject_token, kind: kind)

      record_withdrawal(kind)
    end
    redirect_back fallback_location: root_path, notice: t("consent.withdrawn")
  end

  private
    def record_decision(kind)
      granted = params.dig(:consent, kind) == "1"
      return if granted == ConsentRecord.granted?(subject_token: consent_subject_token, kind: kind)

      if granted
        ConsentRecord.grant(
          subject_token: consent_subject_token,
          kind: kind,
          policy_version: Store.policy_version,
          ip: request.remote_ip,
          user_agent: request.user_agent
        )
      else
        record_withdrawal(kind)
      end
    end

    # Named for what it writes: a private method sharing the action's name would
    # replace the action itself.
    def record_withdrawal(kind)
      ConsentRecord.withdraw(
        subject_token: consent_subject_token,
        kind: kind,
        policy_version: Store.policy_version,
        ip: request.remote_ip,
        user_agent: request.user_agent
      )
    end
end
