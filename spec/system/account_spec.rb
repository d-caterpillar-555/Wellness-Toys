require "rails_helper"

RSpec.describe "An account", type: :system do
  it "creates an account, then shows the order history on the next visit" do
    visit new_user_registration_path

    fill_in I18n.t("auth.fields.name"), with: "Rae Lindqvist"
    fill_in I18n.t("auth.fields.email"), with: "rae@example.com"
    fill_in I18n.t("auth.fields.password"), with: "correct-horse-battery"
    fill_in I18n.t("auth.fields.password_confirmation"), with: "correct-horse-battery"
    check "user_age_confirmed"
    check "user_terms_accepted"
    click_button I18n.t("auth.sign_up.submit")

    expect(page).to have_text(I18n.t("account.dashboard.title"))
    expect(page).to have_text(I18n.t("account.dashboard.orders_empty"))

    click_button I18n.t("account.nav.sign_out")

    user = User.kept.find_by(email: "rae@example.com")
    order = create(:order, :with_item, user: user, email: user.email)

    visit new_user_session_path
    fill_in I18n.t("auth.fields.email"), with: "rae@example.com"
    fill_in I18n.t("auth.fields.password"), with: "correct-horse-battery"
    click_button I18n.t("auth.sign_in.submit")

    expect(page).to have_text(I18n.t("account.dashboard.title"))
    click_link I18n.t("account.orders.title"), match: :first
    expect(page).to have_text(order.number)
  end

  it "keeps the account area behind the sign-in" do
    visit account_root_path

    expect(page).to have_text(I18n.t("auth.sign_in.title"))
  end
end
