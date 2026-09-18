FactoryBot.define do
  factory :author do
    sequence(:name) { |n| "Author #{n}" }
    bio { "DEMO AUTHOR. Writes about sexual health and product safety." }
    # credentials is deliberately left unset. An invented credential is a lie
    # told by the interface, so a test that needs one sets it explicitly.
  end
end
