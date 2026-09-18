class Cart::ItemsController < ApplicationController
  def create
    authorize current_cart, :update?
    variant = Variant.available.find(params[:variant_id])
    quantity = clamped_quantity(params[:quantity])
    return out_of_stock(variant) if quantity > variant.stock_quantity

    current_cart.add_variant!(variant, quantity: quantity)
    flash.now[:notice] = t("cart.items.added", product: variant.product.name)
    render_cart
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def update
    authorize current_cart, :update?
    item = current_cart.cart_items.find(params[:id])
    item.update!(quantity: clamped_quantity(params[:quantity]))
    flash.now[:notice] = t("cart.items.updated")
    render_cart
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroy
    authorize current_cart, :update?
    current_cart.cart_items.find(params[:id]).destroy!
    flash.now[:notice] = t("cart.items.removed")
    render_cart
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private
    # The database CHECK only allows 1..100, so an out-of-range value is
    # clamped here rather than handed to an INSERT that would raise.
    def clamped_quantity(value)
      value.to_i.clamp(CartItem::MIN_QUANTITY, CartItem::MAX_QUANTITY)
    end

    def out_of_stock(variant)
      flash.now[:alert] = t("cart.items.out_of_stock", product: variant.product.name)
      render_cart(status: :unprocessable_entity)
    end

    def render_cart(status: :ok)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: cart_streams, status: status }
        format.html { redirect_to cart_path, notice: flash.now[:notice], alert: flash.now[:alert] }
      end
    end

    # The count in the header and the flash both live outside the form, so a
    # Turbo submit replaces those two regions rather than the whole page.
    def cart_streams
      [
        turbo_stream.replace("cart-count", partial: "carts/count", locals: { cart: current_cart }),
        turbo_stream.replace("flash", partial: "layouts/flash")
      ]
    end
end
