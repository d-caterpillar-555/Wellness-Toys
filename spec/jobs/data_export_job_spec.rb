require "rails_helper"

RSpec.describe DataExportJob, type: :job do
  it "writes the export, attaches it to the request and completes the request" do
    user = create(:user, email: "rae@example.com", name: "Rae Lindqvist")
    create(:order, :with_item, user: user, email: user.email)
    create(:address, user: user)
    ConsentRecord.grant(subject_token: "user-#{user.id}", kind: "functional", policy_version: "1.0", user: user)
    request = create(:data_request, user: user, kind: "export")

    described_class.perform_now(request)

    request.reload
    expect(request.status).to eq("completed")
    expect(request.completed_at).to be_present
    expect(request.export).to be_attached

    body = request.export.download
    expect(body).to include("rae@example.com")
    expect(body).to include("Rae Lindqvist")
    expect(body).to include("functional")
  end

  it "leaves a deletion request alone: a person erasing their data is not asking for a copy" do
    request = create(:data_request, kind: "delete")

    described_class.perform_now(request)

    expect(request.reload.status).to eq("pending")
    expect(request.export).not_to be_attached
  end

  it "does not build a second export for an already completed request" do
    request = create(:data_request, kind: "export")
    described_class.perform_now(request)
    attachment_id = request.reload.export.attachment.id

    described_class.perform_now(request)

    expect(request.reload.export.attachment.id).to eq(attachment_id)
  end

  it "writes the export to the exports service, not the one holding shop imagery" do
    request = create(:data_request, kind: "export")

    described_class.perform_now(request)

    expect(request.reload.export.blob.service_name).to eq("exports")
  end
end
