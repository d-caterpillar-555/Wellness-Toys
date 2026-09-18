# Base for content that an editor or an admin manages in the admin console:
# full CRUD there, and nothing on the storefront. Customer data inherits from
# ApplicationPolicy directly, because its console rules are narrower than this.
class AvoManagedPolicy < ApplicationPolicy
  def avo_create?
    staff?
  end

  def avo_update?
    staff?
  end

  def avo_destroy?
    staff?
  end

  # Content is ordered and related by hand: a category's position, a product's
  # categories, an article's topics.
  def reorder?
    staff?
  end

  def attach?
    staff?
  end

  def detach?
    staff?
  end
end
