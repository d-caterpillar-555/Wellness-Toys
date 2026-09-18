require "rails_helper"

# The whole purchase path, in a browser-shaped session: acknowledge the age gate,
# find the catalogue, open a product, add it to the cart, place the order.
RSpec.describe "Buying something", type: :system do
  it "goes from the home page to a placed order" do
    category = create(:category, name: "Lubricants")
    product = create(:product, :with_variant, name: "Water Based Lubricant", materials: "Medical grade silicone")
    product.categories << category

    visit root_path
    click_button I18n.t("age_gate.confirm")
    expect(page).not_to have_button(I18n.t("age_gate.confirm"))

    click_link "Shop the catalogue"
    expect(page).to have_text("Water Based Lubricant")

    click_link "Water Based Lubricant"
    expect(page).to have_text("Materials and safety")

    click_button I18n.t("products.add_to_cart")

    expect(page).to have_text(I18n.t("cart.heading"))
    expect(page).to have_text("Water Based Lubricant")

    click_link I18n.t("cart.checkout")
    expect(page).to have_text(I18n.t("checkout.title"))

    fill_in I18n.t("checkout.fields.email"), with: "buyer@example.com"
    fill_in I18n.t("checkout.fields.recipient"), with: "A. Customer"
    fill_in I18n.t("checkout.fields.line1"), with: "12 Alder Road"
    fill_in I18n.t("checkout.fields.city"), with: "Bristol"
    fill_in I18n.t("checkout.fields.postal_code"), with: "BS1 4ST"
    fill_in I18n.t("checkout.fields.country_code"), with: "GB"
    click_button I18n.t("checkout.submit")

    expect(page).to have_text(I18n.t("orders.show.eyebrow"))
    expect(page).to have_text(I18n.t("orders.events.created"))
    expect(page).to have_text("Water Based Lubricant")

    expect(Order.kept.count).to eq(1)
    order = Order.kept.last
    expect(order.order_items.count).to eq(1)
    expect(order.email).to eq("buyer@example.com")
    expect(product.variants.first.reload.stock_quantity).to eq(9)
  end

  it "keeps the catalogue reachable from every page it renders" do
    visit root_path

    expect(page).to have_link("Shop", href: shop_path)
    expect(page).to have_link("Learn", href: learn_path)
  end
end
