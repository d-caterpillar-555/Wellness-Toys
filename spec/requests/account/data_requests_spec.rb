require "rails_helper"

RSpec.describe "Account privacy requests", type: :request do
  let(:user) { create(:user) }

  it "sends a signed-out visitor to sign in" do
    get account_data_requests_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "lists only the account's own requests" do
    create(:data_request, user: user, kind: "export")
    create(:data_request, kind: "delete")
    sign_in user

    get account_data_requests_path

    expect(page_text).to include(I18n.t("account.data_requests.kinds.export"))
    expect(page_text).not_to include(I18n.t("account.data_requests.kinds.delete"))
  end

  it "records an export request and enqueues the export job" do
    sign_in user

    expect {
      post account_data_requests_path, params: { data_request: { kind: "export" } }
    }.to change(DataRequest, :count).by(1)
      .and have_enqueued_job(DataExportJob)

    expect(user.data_requests.last.kind).to eq("export")
    expect(response).to redirect_to(account_data_requests_path)
  end

  it "records a deletion request without enqueuing an export" do
    sign_in user

    post account_data_requests_path, params: { data_request: { kind: "delete" } }

    expect(user.data_requests.last.kind).to eq("delete")
    expect(DataExportJob).not_to have_been_enqueued
  end

  it "refuses a kind that is not a known request" do
    sign_in user

    expect {
      post account_data_requests_path, params: { data_request: { kind: "everything" } }
    }.not_to change(DataRequest, :count)

    expect(response).to have_http_status(422)
  end
end
