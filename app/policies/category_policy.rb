# Categories organise the public catalogue, so they are readable by everyone
# and edited in the console.
class CategoryPolicy < AvoManagedPolicy
  def index?
    true
  end

  def show?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept
    end
  end
end
