# == Schema Information
#
# Table name: articles
#
#  id            :integer          not null, primary key
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
require 'rails_helper'

RSpec.describe Article, type: :model do
  subject { FactoryBot.create(:article) }

  it 'is created successfully' do
    expect(subject).to be_valid
  end

  describe 'wordpress_url validation' do
    it 'accepts https URLs' do
      subject.wordpress_url = 'https://example.com/post'
      expect(subject).to be_valid
    end

    it 'rejects javascript URLs' do
      subject.wordpress_url = 'javascript:alert(1)'
      expect(subject).not_to be_valid
      expect(subject.errors[:wordpress_url]).to include('must be a valid http or https URL')
    end
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
