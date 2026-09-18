class OrderConfirmationJob < ApplicationJob
  queue_as :default

  CONFIRMATION_KIND = "confirmation_sent"

  # Idempotent by the event itself: the confirmation_sent OrderEvent is the
  # record that the email went out, so a retry after a partial failure no-ops
  # instead of emailing the customer twice. A boolean column would give the
  # same fact a second home and a second chance to disagree.
  def perform(order)
    return if order.order_events.exists?(kind: CONFIRMATION_KIND)

    OrderMailer.confirmation(order).deliver_now
    order.record_event!(kind: CONFIRMATION_KIND)
  end
end
