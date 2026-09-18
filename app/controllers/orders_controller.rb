class OrdersController < ApplicationController
  # A guest holds the public token as the only credential they have, so an
  # unknown token is a not-found. The sequential order number is never accepted
  # here: it is guessable and is not an access credential.
  def show
    @order = Order.find_by_public_token!(params[:public_token])
    authorize @order, :receipt?
    # No variant include: an order line renders the snapshot it stored, not the
    # live product, so reaching for the association would be a query nothing uses.
    @items = @order.order_items
    @events = @order.order_events.chronological
  end
end
