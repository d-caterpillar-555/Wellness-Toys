class OrderMailer < ApplicationMailer
  default from: Store.support_email

  # The subject names the order number and nothing else. A subject line is
  # shown on a lock screen before any unlock, so naming a product there would
  # disclose a health-adjacent purchase to whoever is looking at the phone. The
  # body may name items because the recipient is the customer.
  def confirmation(order)
    @order = order
    @items = order.order_items
    mail(to: order.email, subject: t("orders.mailer.subject", number: order.number))
  end
end
