# Avo, the admin console.
#
# The console is a staff tool. Only editors and admins reach it, and every
# action inside it is authorized by the application's own policies through
# Avo::PunditResource (see lib/avo/pundit_authorization.rb). Avo Community
# permits every action by default and the add-on that replaces that is paid,
# which this build does not use.
Avo.configure do |config|
  config.root_path = "/admin"
  config.app_name = "Wellness Toys"
  config.current_user_method = :current_user

  config.authenticate_with do
    authenticate_user!
    unless current_user&.staff?
      redirect_to main_app.root_path, alert: I18n.t("account.nav.staff_only")
    end
  end

  # Console actions map to their own policy methods. `index?` on ProductPolicy
  # answers a shopper asking for the catalogue; `avo_index?` answers an editor
  # asking to manage it. Keeping them apart is what stops one surface's rule
  # from silently deciding the other's.
  config.authorization_methods = {
    index: "avo_index?",
    show: "avo_show?",
    edit: "avo_edit?",
    new: "avo_new?",
    update: "avo_update?",
    create: "avo_create?",
    destroy: "avo_destroy?",
    search: "avo_search?"
  }

  config.set_context do
    { current_user: current_user }
  end

  # A failing action inside the console is a 403 with a message, never a silent
  # no-op that looks like success.
  config.explicit_authorization = true
end
