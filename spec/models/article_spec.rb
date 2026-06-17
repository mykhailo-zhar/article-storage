require 'rails_helper'

RSpec.describe Article, type: :model do
  subject { FactoryBot.create(:article) }

  it 'is created successfully' do
    expect(subject).to be_valid
  end

  describe 'categories' do
    let(:category) { FactoryBot.create(:category) }
    let(:article) { FactoryBot.create(:article, categories: [ category ]) }

    it 'can belong to multiple categories' do
      other_category = FactoryBot.create(:category)
      article.categories << other_category

      expect(article.categories).to contain_exactly(category, other_category)
    end

    it 'is removed from join table when destroyed' do
      article
      expect { article.destroy }.to change(ArticleCategory, :count).by(-1)
    end
  end
end
