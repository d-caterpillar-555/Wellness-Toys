require "rails_helper"

RSpec.describe "Registration", type: :request do
  def sign_up_params(**overrides)
    {
      user: {
        name: "Rae Lindqvist",
        email: "rae@example.com",
        password: "correct-horse-battery",
        password_confirmation: "correct-horse-battery",
        age_confirmed: "1",
        terms_accepted: "1"
      }.merge(overrides)
    }
  end

  describe "GET /account/sign_up" do
    it "renders the form" do
      get new_user_registration_path

      expect(response).to have_http_status(:ok)
      expect(page_text).to include(I18n.t("auth.sign_up.title"))
    end
  end

  describe "POST /account" do
    it "creates an account and signs the person in" do
      expect {
        post user_registration_path, params: sign_up_params
      }.to change(User, :count).by(1)

      user = User.kept.find_by(email: "rae@example.com")
      expect(user.name).to eq("Rae Lindqvist")
      expect(user.age_confirmed_at).to be_present
      expect(user.terms_accepted_at).to be_present
      expect(response).to redirect_to(account_root_path)
    end

    it "refuses an account with no age confirmation" do
      expect {
        post user_registration_path, params: sign_up_params(age_confirmed: "0")
      }.not_to change(User, :count)

      expect(response).to have_http_status(422)
    end

    it "refuses an account with the terms not accepted" do
      expect {
        post user_registration_path, params: sign_up_params(terms_accepted: "0")
      }.not_to change(User, :count)

      expect(response).to have_http_status(422)
    end

    it "stores a phone number when one is given" do
      post user_registration_path, params: sign_up_params(phone: "+44 7700 900123")

      expect(User.kept.find_by(email: "rae@example.com").phone).to eq("+44 7700 900123")
    end
  end

  describe "sign in and sign out" do
    let(:user) { create(:user, email: "rae@example.com", password: "correct-horse-battery") }

    it "signs a person in with the right password" do
      post user_session_path, params: { user: { email: user.email, password: "correct-horse-battery" } }

      expect(response).to redirect_to(account_root_path)
    end

    it "refuses the wrong password" do
      post user_session_path, params: { user: { email: user.email, password: "not-the-password" } }

      expect(response).to have_http_status(422)
    end

    it "signs a person out" do
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "password reset" do
    let(:user) { create(:user, email: "rae@example.com") }

    it "emails a reset link" do
      expect {
        post user_password_path, params: { user: { email: user.email } }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
