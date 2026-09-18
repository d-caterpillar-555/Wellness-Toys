FactoryBot.define do
  factory :variant do
    product
    sequence(:name) { |n| "Variant #{n}" }
    sequence(:sku) { |n| format("VAR-%05d", n) }
    price_cents { 2_500 }
    stock_quantity { 10 }
  end
end
