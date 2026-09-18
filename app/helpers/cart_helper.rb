module CartHelper
  # The subtotal as a price, rendered the same way every other money figure on
  # the site is rendered.
  def cart_total_label(cart)
    price(cart.subtotal_cents)
  end

  # The quantities a line stepper offers. The cart allows up to 100, but the
  # common case is a handful, so the stepper stays short and the server clamps.
  def quantity_options
    (1..10).to_a
  end
end
