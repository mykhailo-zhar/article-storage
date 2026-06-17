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
class Category < ApplicationRecord
  belongs_to :parent,
    class_name: "Category",
    optional: true

  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories
end
