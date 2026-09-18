# A collection is a curated view over the public catalogue, not a stored row,
# so the policy answers for the surface rather than for a record. It exists so
# the action is authorised explicitly instead of skipped.
class CollectionPolicy < ApplicationPolicy
  def show?
    true
  end
end
