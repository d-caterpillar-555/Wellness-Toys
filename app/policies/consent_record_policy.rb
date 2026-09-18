# Consent is recorded per subject: an account records decisions for itself, and
# a guest records them against the token in their session. Consent records are
# append-only, so there is no destroy rule and an edit is really a second row.
#
# #update? governs the act of recording a decision, not a comparison against one
# stored row: the controller derives the subject token from the signed-in
# account, so a decision can only ever be written for the actor's own consent.
class ConsentRecordPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    true
  end

  def update?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
