# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  name         :string
#  slug         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  parent_id    :integer
#  wordpress_id :integer
#
# Indexes
#
#  index_categories_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  parent_id  (parent_id => categories.id) ON DELETE => nullify ON UPDATE => cascade
#
FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
    slug { Faker::Internet.slug }
    parent { nil }
    wordpress_id { Faker::Number.unique.number(digits: 5) }
  end
end
