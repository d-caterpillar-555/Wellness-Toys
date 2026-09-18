FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article #{n}" }
    kind { "guide" }
    status { "draft" }

    # A published article must carry a published_at (a database CHECK), so the
    # trait sets both. The bare factory stays a draft and is never counted in a
    # published scope by accident.
    trait :published do
      status { "published" }
      published_at { 1.day.ago }
    end

    trait :guide do
      kind { "guide" }
    end

    trait :post do
      kind { "post" }
    end

    trait :glossary do
      kind { "glossary" }
    end

    trait :with_sources do
      after(:create) { |article| create_list(:source, 2, article: article) }
    end
  end
end
