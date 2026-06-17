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
require 'rails_helper'

RSpec.describe ArticleCategory, type: :model do
  subject { FactoryBot.build(:article_category) }

  it 'is valid with an article and category' do
    expect(subject).to be_valid
  end

  it 'does not allow duplicate article-category pairs' do
    existing = FactoryBot.create(:article_category)
    duplicate = FactoryBot.build(:article_category, article: existing.article, category: existing.category)

    expect(duplicate).not_to be_valid
  end
end
