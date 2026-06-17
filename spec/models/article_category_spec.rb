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
