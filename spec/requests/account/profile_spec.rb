require "rails_helper"

RSpec.describe "Account profile", type: :request do
  let(:user) { create(:user, name: "Rae Lindqvist") }

  it "sends a signed-out visitor to sign in" do
    get account_profile_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders the profile" do
    sign_in user

    get account_profile_path

    expect(response).to have_http_status(:ok)
    expect(page_text).to include("Rae Lindqvist")
  end

  it "updates the name and phone" do
    sign_in user

    patch account_profile_path, params: { user: { name: "Rae L", phone: "+44 7700 900456" } }

    expect(response).to redirect_to(account_profile_path)
    expect(user.reload.name).to eq("Rae L")
    expect(user.phone).to eq("+44 7700 900456")
  end

  it "re-renders the form when the name is blank" do
    sign_in user

    patch account_profile_path, params: { user: { name: "" } }

    expect(response).to have_http_status(422)
    expect(user.reload.name).to eq("Rae Lindqvist")
  end

  it "cannot change another account's profile" do
    other = create(:user, name: "Someone Else")
    sign_in user

    patch account_profile_path, params: { user: { name: "Taken Over" } }

    expect(other.reload.name).to eq("Someone Else")
  end
end
