# Search reads the public catalogue and the published library, both of which
# carry their own scopes. This policy exists so the action is authorised
# explicitly; the visibility rule is the two scopes it delegates to.
class SearchPolicy < ApplicationPolicy
  def show?
    true
  end
end
