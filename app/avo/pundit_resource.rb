# Every Avo resource inherits from this class rather than from
# Avo::BaseResource, so the console is authorized by the application's own
# Pundit policies. See lib/avo/pundit_authorization.rb for why the adapter
# exists and how `avo_*?` keeps console rules apart from storefront rules.
#
# It is abstract: Avo's navigation lists every descendant of its base resource,
# and this one stands for all of them rather than for a single model.
class Avo::PunditResource < Avo::BaseResource
  abstract_resource!

  def authorization(user: nil)
    Avo::PunditAuthorization.new(
      user || Avo::Current.user,
      record || model_class,
      policy_class: authorization_policy
    )
  end
end
