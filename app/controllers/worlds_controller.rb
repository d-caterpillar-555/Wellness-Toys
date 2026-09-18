# The gallery: what the eight worlds are, in one place.
#
# This is not a world. It is the index of the eight, written in the default
# architecture's clothes, and it exists because a reviewer needs one page that
# explains the whole set without visiting all of them.
#
# It renders a static registry of design worlds, not database records, so the
# policy-scoping convention does not apply here - the same reason the session
# and password controllers skip it. Nothing about the store is exposed.
class WorldsController < ApplicationController
  layout "application"

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @worlds = World.all
    @current = World.all.find { |world| world.current?(request) }
  end
end
