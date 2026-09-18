class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  helper_method :cart_item_count

  private
    # The count shown beside the cart link. Carts do not exist yet, so this is
    # genuinely zero rather than a placeholder. It becomes a query against the
    # current cart when commerce lands.
    def cart_item_count
      0
    end

    def render_forbidden
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "You are not allowed to do that." }
        format.any { head :forbidden }
      end
    end
end
