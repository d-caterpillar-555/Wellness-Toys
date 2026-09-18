class Account::OrdersController < Account::BaseController
  PER_PAGE = 10

  def index
    @pagy, @orders = pagy(:offset, policy_scope(Order).recent_first, limit: PER_PAGE)
  end

  def show
    @order = policy_scope(Order).find_by!(number: params[:number])
    authorize @order
    # No variant include: an order line renders the snapshot it stored, not the
    # live product, so reaching for the association would be a query nothing uses.
    @items = @order.order_items
    @events = @order.order_events.chronological
  end
end
