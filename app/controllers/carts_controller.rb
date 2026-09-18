class CartsController < ApplicationController
  # Items are eager loaded with their variant and product because the line
  # partial reads both names and the price, and a cart is small enough that one
  # query per line is pure waste.
  def show
    @cart = current_cart
    authorize @cart
    @items = @cart.cart_items.in_order.includes(variant: :product)
  end
end
