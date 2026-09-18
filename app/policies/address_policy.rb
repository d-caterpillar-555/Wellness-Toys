# An address belongs to the account that owns it. The street lines are
# encrypted and are health-adjacent data, so reading somebody else's address is
# the sharpest version of this failure: the policy refuses it outright.
#
# Staff read addresses in the console because a parcel needs one. They cannot
# change or delete a customer's address: that is the customer's own to edit.
class AddressPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner?
  end

  def create?
    user.present?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
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
