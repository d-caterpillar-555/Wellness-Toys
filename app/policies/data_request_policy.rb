# A privacy request belongs to the person who made it. Staff may work it in the
# admin console; through the storefront an account only ever sees its own.
class DataRequestPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner?
  end

  def create?
    user.present?
  end

  def avo_update?
    staff?
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
