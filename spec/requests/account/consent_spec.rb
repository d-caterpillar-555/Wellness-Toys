require "rails_helper"

RSpec.describe "Account consent", type: :request do
  let(:user) { create(:user) }

  it "sends a signed-out visitor to sign in" do
    get account_consent_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "shows the account's current choices" do
    ConsentRecord.grant(subject_token: "user-#{user.id}", kind: "analytics", policy_version: "1.0", user: user)
    sign_in user

    get account_consent_path

    expect(response).to have_http_status(:ok)
    expect(page_text).to include(I18n.t("account.consent.kinds.analytics"))
  end

  it "records a grant as a new row" do
    sign_in user

    expect {
      patch account_consent_path, params: { consent: { analytics: "1" } }
    }.to change(ConsentRecord, :count).by(1)

    record = ConsentRecord.chronological.last
    expect(record.kind).to eq("analytics")
    expect(record.revoked_at).to be_nil
    expect(record.user).to eq(user)
  end

  it "records a withdrawal as a second row, never an edit" do
    ConsentRecord.grant(subject_token: "user-#{user.id}", kind: "analytics", policy_version: "1.0", user: user)
    sign_in user

    expect {
      patch account_consent_path, params: { consent: { analytics: "0" } }
    }.to change(ConsentRecord, :count).by(1)

    rows = ConsentRecord.chronological.where(kind: "analytics")
    expect(rows.count).to eq(2)
    expect(rows.first.revoked_at).to be_nil
    expect(rows.last.revoked_at).to be_present
    expect(ConsentRecord.granted?(subject_token: "user-#{user.id}", kind: "analytics")).to be false
  end

  it "writes nothing when the choice has not changed" do
    ConsentRecord.grant(subject_token: "user-#{user.id}", kind: "functional", policy_version: "1.0", user: user)
    sign_in user

    expect {
      patch account_consent_path, params: { consent: { functional: "1" } }
    }.not_to change(ConsentRecord, :count)
  end
end
