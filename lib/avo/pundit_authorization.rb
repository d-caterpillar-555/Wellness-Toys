module Avo
  # The authorization adapter Avo's resources use, backed by this application's
  # Pundit policies.
  #
  # Avo Community ships a service that permits every action. Per-action
  # authorization lives in the paid avo-authorization add-on, and this build
  # deliberately stays on the free tier, so the application supplies the
  # adapter instead: every question Avo asks is answered by a Pundit policy.
  #
  # Avo asks about two surfaces with the same action name. The console maps its
  # actions through Avo.configuration.authorization_methods to the `avo_*?`
  # methods, so an answer written for a customer-facing route is never reused
  # for the console by accident.
  class PunditAuthorization
    class << self
      # Used when building the navigation: which resources may this person open
      # at all.
      def authorize(user, record, action, policy_class: nil, raise_exception: false, **)
        new(user, record, policy_class: policy_class).authorize(action, raise_exception: raise_exception)
      end
    end

    def initialize(user, record, policy_class: nil)
      @user = user
      @record = record
      @policy_class = policy_class
    end

    def set_record(record)
      @record = record
      self
    end

    def authorize_action(action, record: nil, **options)
      @record = record if record
      authorize(action, **options)
    end

    # Raises on denial by default, which is what turns an unauthorized console
    # action into Avo's own unauthorized screen instead of a silent no-op. UI
    # probes ask for a boolean instead.
    def authorize(action, raise_exception: true, **)
      method = policy_method(action)
      allowed = policy.public_send(method)
      return allowed if allowed || !raise_exception

      raise Avo::NotAuthorizedError, "#{method} refused for #{user ? "user #{user.id}" : "a guest"}"
    rescue Pundit::NotDefinedError => error
      raise Avo::NoPolicyError, error.message
    end

    def has_method?(action, **)
      policy.respond_to?(policy_method(action))
    rescue Pundit::NotDefinedError
      false
    end

    # Avo scopes its index and search queries through this. A model without a
    # policy scope resolves to nothing, which is the safe direction: an
    # unlisted surface fails closed rather than listing every row.
    def apply_policy(query)
      if @policy_class
        @policy_class::Scope.new(user, query).resolve
      else
        Pundit.policy_scope!(user, query)
      end
    rescue NameError, NotImplementedError, Pundit::NotDefinedError
      query.none
    end

    private
      attr_reader :user, :record

      # Pundit's policy! does not take a policy class, so a resource that names
      # one gets it constructed directly.
      def policy
        if @policy_class
          @policy_class.new(user, record)
        else
          Pundit.policy!(user, record)
        end
      end

      def policy_method(action)
        name = action.to_s
        mapped = Avo.configuration.authorization_methods.stringify_keys[name]
        mapped.presence || (name.end_with?("?") ? name : "#{name}?")
      end
  end
end
