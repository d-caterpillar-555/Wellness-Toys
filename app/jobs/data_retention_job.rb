# The scheduled tidy-up. Two windows are enforced here:
#
#   * an abandoned cart is deleted after 30 days. A cart names a person's
#     intended purchases, which is health-adjacent data, so it should not sit in
#     the database forever waiting for a visitor who moved on.
#   * a completed data export is deleted after seven days. A copy of somebody's
#     data in storage is a liability, not an asset, and the request record keeps
#     the fact that it was produced.
#
# Scheduled from config/recurring.yml in production.
class DataRetentionJob < ApplicationJob
  queue_as :default

  CART_RETENTION = 30.days
  EXPORT_RETENTION = 7.days

  def perform
    purge_stale_carts
    purge_old_exports
  end

  private
    def purge_stale_carts
      Cart.stale.find_each(&:destroy!)
    end

    def purge_old_exports
      DataRequest.completed.where(completed_at: ...EXPORT_RETENTION.ago).find_each do |request|
        request.export.purge if request.export.attached?
      end
    end
end
