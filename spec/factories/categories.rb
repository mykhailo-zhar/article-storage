FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
    slug { Faker::Internet.slug }
    parent { nil }
    wordpress_id { Faker::Number.unique.number(digits: 5) }
  end
end
