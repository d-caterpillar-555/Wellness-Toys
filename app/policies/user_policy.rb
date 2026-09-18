# An account belongs to one person. There is no staff override on the storefront
# actions: work that support needs to do to an account happens in the admin
# console, where it is recorded, not through a storefront route.
#
# In the console, staff may read accounts and correct a name or a role. They
# cannot create one (accounts are the customer's own to make) or destroy one:
# erasure runs through a data request, which leaves the anonymised order history
# that tax and consumer law require.
class UserPolicy < ApplicationPolicy
  def show?
    owner?
  end

  def update?
    owner?
  end

  def avo_update?
    staff?
  end

  private
    def owner?
      user.present? && record.id == user.id
    end
end
