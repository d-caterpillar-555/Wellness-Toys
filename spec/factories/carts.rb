FactoryBot.define do
  # A cart belongs to exactly one owner: a signed-in customer or a guest token.
  # The bare factory is the guest cart, since that is the first cart most
  # visitors ever have.
  factory :cart do
    guest_token { SecureRandom.urlsafe_base64(24) }

    trait :for_user do
      user
      guest_token { nil }
    end

    trait :with_item do
      after(:create) { |cart| create(:cart_item, cart: cart) }
    end
  end

  factory :cart_item do
    cart
    variant
    quantity { 1 }
  end
end
