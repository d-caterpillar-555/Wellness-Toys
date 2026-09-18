require "rails_helper"

RSpec.describe "Age gate", type: :request do
  it "asks until it is acknowledged" do
    get root_path

    expect(page_text).to include(I18n.t("age_gate.heading"))
    expect(page_text).to include(I18n.t("age_gate.confirm"))
  end

  it "records the acknowledgement and stops asking" do
    post age_confirmation_path

    expect(response).to redirect_to(root_path)

    get root_path
    expect(page_text).not_to include(I18n.t("age_gate.confirm"))
  end

  it "is soft: the catalogue is readable before it is acknowledged" do
    get shop_path

    expect(response).to have_http_status(:ok)
  end

  it "does not store the acknowledgement as a consent record" do
    expect {
      post age_confirmation_path
    }.not_to change(ConsentRecord, :count)
  end
end
