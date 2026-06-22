# == Schema Information
#
# Table name: articles
#
#  id            :integer          not null, primary key
#  description   :text
#  embedding     :binary(384)
#  excerpt       :text
#  published_at  :datetime
#  title         :string
#  wordpress_url :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  wordpress_id  :integer
#
# Indexes
#
#  index_articles_on_wordpress_id  (wordpress_id) UNIQUE
#
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
