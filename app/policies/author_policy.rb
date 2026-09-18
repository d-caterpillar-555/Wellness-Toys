# Writers are public bylines, and are onboarded in the console. The credentials
# on the page are the author's own words; the policy has nothing to add.
class AuthorPolicy < AvoManagedPolicy
  def index?
    true
  end

  def show?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept_active
    end
  end
end
