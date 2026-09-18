# The default is deny. A policy that says nothing permits nothing, so a new
# action on an existing controller fails closed until someone writes down who
# may do it. Nothing is public by accident, and every rule has one home.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # The admin console asks its own questions. Avo maps its actions to these
  # methods (config/initializers/avo.rb), so an answer written for a storefront
  # route is never reused for the console by accident. Reads, previews and the
  # actions menu are for staff; anything that changes a record or its
  # associations defaults to deny, so a resource has to say explicitly that the
  # console may change it.
  def avo_index?
    staff?
  end

  def avo_show?
    staff?
  end

  def avo_search?
    staff?
  end

  def avo_create?
    false
  end

  def avo_new?
    avo_create?
  end

  def avo_update?
    false
  end

  def avo_edit?
    avo_update?
  end

  def avo_destroy?
    false
  end

  def act_on?
    staff?
  end

  def preview?
    staff?
  end

  def reorder?
    false
  end

  def attach?
    false
  end

  def detach?
    false
  end

  private
    # Editors and admins. Changes to published content happen in the admin
    # console, not through a storefront form.
    def staff?
      user.present? && user.staff?
    end

    # Ownership is a user_id on the record, which is the shape every owned
    # resource in this schema has (orders, addresses, data requests).
    def owner?
      user.present? && record.respond_to?(:user_id) && record.user_id == user.id
    end

  # A policy scope is the read side of the same rule: what a person is allowed
  # to see listed. It is resolved rather than defaulted, so forgetting to write
  # one raises instead of quietly returning everything.
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class} must implement #resolve"
    end

    private
      def staff?
        user.present? && user.staff?
      end
  end
end
