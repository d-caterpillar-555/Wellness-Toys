FactoryBot.define do
  factory :data_request do
    user
    kind { "export" }
  end

  factory :consent_record do
    subject_token { "guest-#{SecureRandom.hex(8)}" }
    kind { "functional" }
    granted_at { Time.current }
    policy_version { "1.0" }
  end
end
