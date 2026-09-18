# Topic hubs are the navigation of the education library. Public to read,
# staff-managed in the console.
class TopicPolicy < AvoManagedPolicy
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
