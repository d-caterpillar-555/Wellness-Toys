# A cart belongs to the visitor who built it. The cart is resolved from the
# session (guest token) or from the signed-in account (see CartScoped), so this
# policy is a second lock on the same door: it refuses a cart that belongs to
# somebody else's account, which is the case a session bug would produce.
#
# The console may see that a cart exists and never edit one: an in-progress
# basket is the shopper's, and the retention job deletes abandoned ones.
class CartPolicy < ApplicationPolicy
  def show?
    guest_cart? || owned_by_user?
  end

  def update?
    show?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.for_user(user)
      else
        scope.none
      end
    end
  end

  private
    def guest_cart?
      record.user_id.nil? && record.guest_token.present?
    end

    def owned_by_user?
      user.present? && record.user_id == user.id
    end
end
