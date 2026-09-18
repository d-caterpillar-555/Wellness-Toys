require "rails_helper"

RSpec.describe OrderConfirmationJob, type: :job do
  let(:order) { create(:order, :with_item) }

  it "emails the customer and records the event" do
    expect {
      described_class.perform_now(order)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(order.order_events.exists?(kind: described_class::CONFIRMATION_KIND)).to be true
  end

  it "sends nothing on a retry, because the event is the record that it sent" do
    described_class.perform_now(order)

    expect {
      described_class.perform_now(order)
    }.not_to change { ActionMailer::Base.deliveries.count }
  end

  it "keeps the product out of the subject line" do
    described_class.perform_now(order)

    subject = ActionMailer::Base.deliveries.last.subject
    expect(subject).to include(order.number)
    expect(subject).not_to include(order.order_items.first.product_name)
  end

  it "sends to the address the order was placed with" do
    described_class.perform_now(order)

    expect(ActionMailer::Base.deliveries.last.to).to eq([ order.email ])
  end
end
