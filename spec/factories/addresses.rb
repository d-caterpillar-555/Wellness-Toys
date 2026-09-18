FactoryBot.define do
  factory :address do
    user
    recipient { "A. Customer" }
    line1 { "12 Alder Road" }
    city { "Bristol" }
    postal_code { "BS1 4ST" }
    country_code { "GB" }

    # The two defaults are mutually exclusive in the database (a CHECK), and
    # only one address per user may hold each one (a partial unique index), so
    # they are separate traits rather than a boolean pair on one row.
    trait :default_shipping do
      default_shipping { true }
    end

    trait :default_billing do
      default_billing { true }
    end
  end
end
