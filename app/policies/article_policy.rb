# The education library is public reading, and is written in the console.
class ArticlePolicy < AvoManagedPolicy
  def index?
    true
  end

  def show?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.published.kept
    end
  end
end
