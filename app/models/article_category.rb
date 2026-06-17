# == Schema Information
#
# Table name: article_categories
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  article_id  :integer          not null
#  category_id :integer          not null
#
# Indexes
#
#  index_article_categories_on_article_id                  (article_id)
#  index_article_categories_on_article_id_and_category_id  (article_id,category_id) UNIQUE
#  index_article_categories_on_category_id                 (category_id)
#
# Foreign Keys
#
#  article_id   (article_id => articles.id)
#  category_id  (category_id => categories.id)
#
class ArticleCategory < ApplicationRecord
  belongs_to :article
  belongs_to :category

  validates :article_id, uniqueness: { scope: :category_id }
end
