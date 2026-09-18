FactoryBot.define do
  factory :order do
    email { "buyer@example.com" }
    ship_to_recipient { "A. Customer" }
    ship_to_line1 { "12 Alder Road" }
    ship_to_city { "Bristol" }
    ship_to_postal_code { "BS1 4ST" }
    ship_to_country_code { "GB" }

    # The idempotency key a checkout form would have supplied. Orders are never
    # created without one, so the factory supplies a fresh one per record.
    checkout_token { SecureRandom.uuid }

    trait :with_item do
      after(:create) { |order| create(:order_item, order: order) }
    end
  end

  factory :order_item do
    order
    variant
    quantity { 1 }
    # The name, sku and price columns are snapshots copied from the variant by
    # the model, so the factory does not restate them.
  end
end
