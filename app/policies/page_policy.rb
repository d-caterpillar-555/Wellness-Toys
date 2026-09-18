# Trust pages are public reading, written in the console. `home` has no record
# of its own: the landing page is composed from catalogue and education data,
# each scoped by its own policy, so what this authorises is the surface.
class PagePolicy < AvoManagedPolicy
  def home?
    true
  end

  def show?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.published
    end
  end
end
