require "rails_helper"

RSpec.describe DataRetentionJob, type: :job do
  it "deletes carts abandoned for longer than the retention window" do
    stale = create(:cart)
    stale.update_columns(updated_at: 31.days.ago)
    fresh = create(:cart)

    described_class.perform_now

    expect(Cart.exists?(stale.id)).to be false
    expect(Cart.exists?(fresh.id)).to be true
  end

  it "deletes a stale cart's lines with it" do
    stale = create(:cart)
    create(:cart_item, cart: stale)
    stale.update_columns(updated_at: 31.days.ago)

    described_class.perform_now

    expect(CartItem.where(cart_id: stale.id)).to be_empty
  end

  it "purges an export past its own retention window and keeps the request record" do
    request = create(:data_request, kind: "export")
    DataExportJob.perform_now(request)
    expect(request.reload.export).to be_attached

    request.update_columns(completed_at: 8.days.ago)

    described_class.perform_now

    expect(request.reload.export).not_to be_attached
    expect(request.status).to eq("completed")
  end

  it "keeps a recent export" do
    request = create(:data_request, kind: "export")
    DataExportJob.perform_now(request)

    described_class.perform_now

    expect(request.reload.export).to be_attached
  end
end
