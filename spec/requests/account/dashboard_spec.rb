require "rails_helper"

RSpec.describe "Account dashboard", type: :request do
  let(:user) { create(:user) }

  it "sends a signed-out visitor to sign in" do
    get account_root_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders the dashboard for the signed-in person" do
    sign_in user

    get account_root_path

    expect(response).to have_http_status(:ok)
    expect(page_text).to include(I18n.t("account.dashboard.title"))
  end

  it "shows only the signed-in person's orders" do
    mine = create(:order, user: user, email: user.email)
    theirs = create(:order, email: "someone-else@example.com")
    sign_in user

    get account_root_path

    expect(page_text).to include(mine.number)
    expect(page_text).not_to include(theirs.number)
  end
end
