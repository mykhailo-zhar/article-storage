FactoryBot.define do
  factory :article do
    title { Faker::Lorem.sentence }
    excerpt { Faker::Lorem.paragraph }
    wordpress_url { Faker::Internet.url }
    wordpress_id { Faker::Number.unique.number(digits: 6) }
    published_at { Faker::Time.backward }

    trait :with_categories do
      categories { [ association(:category) ] }
    end
  end
end
