# The age gate is a soft gate: anyone may acknowledge it, and the answer is
# recorded in their own session. There is no record to protect and nothing to
# read back, so the policy only documents that the action is deliberate rather
# than a route someone forgot to guard.
class AgeConfirmationPolicy < ApplicationPolicy
  def create?
    true
  end
end
