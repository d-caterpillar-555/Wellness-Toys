class CheckoutsController < ApplicationController
  # The order columns the customer actually fills in. Everything else on an
  # order is assigned by the model or by this controller.
  ORDER_FIELDS = %i[
    email ship_to_recipient ship_to_line1 ship_to_line2
    ship_to_city ship_to_region ship_to_postal_code ship_to_country_code
  ].freeze

  def new
    authorize Order, :new?
    if current_cart.empty?
      redirect_to_empty_cart
    else
      @order = Order.new(prefilled_attributes)
      # A fresh token per rendered form. The unique index on checkout_token is
      # what makes a resubmitted form a single order, not a second one.
      @order.checkout_token = SecureRandom.uuid
    end
  end

  def create
    authorize Order, :create?
    existing = existing_order
    if existing
      # Checked before the empty cart: the first submit is what emptied it, so
      # a repeat submit belongs with its order rather than back in the cart.
      redirect_to_order(existing)
    elsif current_cart.empty?
      redirect_to_empty_cart
    else
      complete_checkout(create_order)
    end
  rescue ActiveRecord::RecordNotUnique
    # The expected "user double-clicked Place order" outcome: the first request
    # won the unique index, so this one adopts that order instead of erroring.
    redirect_to_order(Order.kept.find_by!(checkout_token: checkout_token))
  rescue ActiveRecord::RecordInvalid => error
    render_form(error.record)
  rescue Variant::OutOfStockError
    render_out_of_stock
  end

  private
    # Everything that mutates the database happens inside one transaction, and
    # no external call is made inside it. The confirmation email is enqueued
    # only after this returns and the transaction has committed.
    def create_order
      order = nil
      ActiveRecord::Base.transaction do
        order = Order.new(order_attributes)
        order.save!
        add_items(order)
        order.recalculate_totals!
        order.record_event!(kind: "created")
      end
      order
    end

    # Stock is taken with one conditional UPDATE per line: decrement_stock!
    # raises rather than overselling, and that raise rolls the whole order back.
    def add_items(order)
      line_items.each do |item|
        @sold_out_variant = item.variant
        item.variant.decrement_stock!(item.quantity)
        add_line_item(order, item)
      end
    end

    def add_line_item(order, cart_item)
      order_item = OrderItem.build_from_cart_item(cart_item)
      order_item.order = order
      order_item.save!
    end

    def complete_checkout(order)
      current_cart.cart_items.destroy_all
      OrderConfirmationJob.perform_later(order)
      redirect_to_order(order, notice: t("checkout.created", number: order.number))
    end

    def redirect_to_order(order, **options)
      redirect_to order_path(order.public_token), status: :see_other, **options
    end

    # Nothing to buy is a message for the cart page, not a validation error on
    # a form that could never be valid.
    def redirect_to_empty_cart
      redirect_to cart_path, alert: t("checkout.empty_cart")
    end

    def render_form(order)
      @order = order
      render :new, status: :unprocessable_entity
    end

    def render_out_of_stock
      @order = Order.new(order_attributes)
      @order.checkout_token = checkout_token
      flash.now[:alert] = t("checkout.out_of_stock", product: sold_out_product_name)
      render :new, status: :unprocessable_entity
    end

    def sold_out_product_name
      @sold_out_variant&.product&.name || t("checkout.out_of_stock_generic")
    end

    def existing_order
      Order.kept.find_by(checkout_token: checkout_token)
    end

    def line_items
      current_cart.cart_items.includes(variant: :product)
    end

    def order_attributes
      attributes = checkout_params.to_h.symbolize_keys.slice(*ORDER_FIELDS)
      attributes[:email] = attributes[:email].to_s.strip.downcase
      # orders_country_is_iso_code requires an upper-case two-letter code.
      attributes[:ship_to_country_code] = attributes[:ship_to_country_code].to_s.strip.upcase
      attributes.merge(user: current_user, checkout_token: checkout_token)
    end

    def prefilled_attributes
      address = default_address
      {
        email: current_user&.email,
        ship_to_recipient: address&.recipient,
        ship_to_line1: address&.line1,
        ship_to_line2: address&.line2,
        ship_to_city: address&.city,
        ship_to_region: address&.region,
        ship_to_postal_code: address&.postal_code,
        ship_to_country_code: address&.country_code
      }
    end

    def default_address
      current_user&.addresses&.default_shipping&.first
    end

    def checkout_token
      checkout_params[:checkout_token].to_s
    end

    def checkout_params
      @checkout_params ||= params.require(:checkout).permit(:checkout_token, *ORDER_FIELDS)
    end
end
