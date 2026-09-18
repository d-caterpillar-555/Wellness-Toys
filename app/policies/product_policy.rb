# The catalogue is public. Anyone may read it; nobody may change it through the
# storefront. The scope is what keeps drafts, retired products and unpublished
# variants out of the list, instead of each controller remembering to ask.
#
# In the console an editor manages the catalogue in full (AvoManagedPolicy).
class ProductPolicy < AvoManagedPolicy
  def index?
    true
  end

  def show?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.available
    end
  end
end
