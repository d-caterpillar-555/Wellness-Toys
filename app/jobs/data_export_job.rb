# Builds the copy of a person's data that a privacy request asks for.
#
# The export is attached to the request itself, so what was produced and when is
# verifiable afterwards, and it is written to the exports storage service rather
# than the one that holds product imagery.
#
# Idempotent enough to retry: a completed request is left alone, and only one
# export is ever attached.
class DataExportJob < ApplicationJob
  queue_as :default

  EXPORT_KIND = "export"

  def perform(data_request)
    return unless data_request.kind == EXPORT_KIND
    return if data_request.completed?

    data_request.update!(status: "processing")
    attach_export(data_request)
    data_request.complete!(note: I18n.t("account.data_requests.export_note"))
  end

  private
    def attach_export(data_request)
      data_request.export.attach(
        io: StringIO.new(payload_for(data_request.user)),
        filename: "wellness-toys-data-#{data_request.id}.json",
        content_type: "application/json"
      )
    end

    # Only what the account actually holds. Order items are the snapshot rows,
    # not live product data, so the export states what was bought at the time.
    def payload_for(user)
      JSON.pretty_generate(
        exported_at: Time.current.iso8601,
        account: {
          email: user.email,
          name: user.name,
          phone: user.phone,
          created_at: user.created_at.iso8601
        },
        orders: user.orders.recent_first.map { |order| order_payload(order) },
        addresses: user.addresses.kept.recent_first.map(&:one_line),
        consent: user.consent_records.chronological.map { |record| consent_payload(record) },
        requests: user.data_requests.recent_first.map { |request| request_payload(request) }
      )
    end

    def order_payload(order)
      {
        number: order.number,
        status: order.status,
        payment_status: order.payment_status,
        placed_at: order.placed_at&.iso8601,
        total_cents: order.total_cents,
        currency: order.currency,
        items: order.order_items.map do |item|
          { product_name: item.product_name, variant_name: item.variant_name, sku: item.sku, quantity: item.quantity, unit_price_cents: item.unit_price_cents }
        end
      }
    end

    def consent_payload(record)
      { kind: record.kind, granted_at: record.granted_at.iso8601, revoked_at: record.revoked_at&.iso8601, policy_version: record.policy_version }
    end

    def request_payload(request)
      { kind: request.kind, status: request.status, requested_at: request.requested_at.iso8601, completed_at: request.completed_at&.iso8601 }
    end
end
