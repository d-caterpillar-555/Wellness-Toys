FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand #{n}" }
    country_code { "GB" }
  end
end
