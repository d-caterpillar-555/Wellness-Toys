# An order is placed by a guest or by a customer, and two different questions
# are asked of it on two different routes:
#
#   receipt? - the public /orders/:public_token page. Holding the token is the
#              credential. It is 24 random bytes, never derived from the order
#              number, and the number itself is refused as a credential.
#   show?    - the account area, where the order must belong to the signed-in
#              customer.
#
# In the console, staff move an order through its states and read its history.
# They cannot destroy one: an order is a financial record, and cancellation is a
# status, not a deletion.
class OrderPolicy < ApplicationPolicy
  def create?
    true
  end

  def new?
    create?
  end

  def receipt?
    true
  end

  def show?
    owner? || staff?
  end

  def avo_update?
    staff?
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
end
