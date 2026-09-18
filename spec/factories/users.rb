FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer-#{n}@example.com" }
    password { "plaintext-password-123" }

    # Both facts are database NOT NULL columns and registrations refuse without
    # them, so the factory states them rather than leaving a half-built account.
    age_confirmed_at { 1.day.ago }
    terms_accepted_at { 1.day.ago }

    trait :admin do
      role { "admin" }
    end

    trait :editor do
      role { "editor" }
    end
  end
end
