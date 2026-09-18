FactoryBot.define do
  factory :source do
    sequence(:title) { |n| "Source #{n}" }
    publisher { "World Health Organization" }
    url { "https://www.who.int/health-topics/sexual-health" }
    published_on { Date.new(2019, 5, 1) }
    association :article
  end
end
