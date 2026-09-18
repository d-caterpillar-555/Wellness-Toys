FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:sku) { |n| format("PRD-%05d", n) }
    subtitle { "A product described plainly, without a claim attached." }

    # An active product must carry a published_at (a database CHECK), so the
    # factory publishes by default and a draft is an explicit override.
    status { "active" }
    published_at { 1.day.ago }

    trait :with_variant do
      after(:create) { |product| create(:variant, product: product) }
    end
  end
end
