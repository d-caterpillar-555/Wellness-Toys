require "rails_helper"

RSpec.describe "Public consent", type: :request do
  def acknowledged
    post age_confirmation_path
  end

  it "asks once the age gate is answered" do
    acknowledged

    get root_path

    expect(page_text).to include(I18n.t("consent.heading"))
  end

  it "records the chosen kinds" do
    expect {
      post consent_path, params: { consent: { functional: "1", analytics: "1" } }
    }.to change(ConsentRecord, :count).by(2)

    expect(ConsentRecord.granted?(subject_token: ConsentRecord.chronological.last.subject_token, kind: "functional")).to be true
    expect(ConsentRecord.granted?(subject_token: ConsentRecord.chronological.last.subject_token, kind: "marketing")).to be false
  end

  it "stops asking once a decision is recorded" do
    post consent_path, params: { consent: { functional: "1" } }

    get root_path
    expect(page_text).not_to include(I18n.t("consent.accept_all"))
  end

  it "writes nothing when the answer has not changed" do
    post consent_path, params: { consent: { functional: "1" } }

    expect {
      post consent_path, params: { consent: { functional: "1" } }
    }.not_to change(ConsentRecord, :count)
  end

  it "withdraws as a second record rather than an edit" do
    post consent_path, params: { consent: { functional: "1", analytics: "1" } }

    expect {
      post withdraw_consent_path
    }.to change(ConsentRecord, :count).by(2)

    expect(ConsentRecord.chronological.last.revoked_at).to be_present
  end

  it "keeps a guest's decision on their own subject token" do
    post consent_path, params: { consent: { functional: "1" } }
    record = ConsentRecord.chronological.last

    expect(record.subject_token).to be_present
    expect(record.user).to be_nil
  end
end
