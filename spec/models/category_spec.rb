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
require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:parent) { FactoryBot.create(:category) }
  let(:category) { FactoryBot.create(:category, parent: parent) }
  subject { category }

  it 'is created successfully' do
    expect(subject).to be_valid
  end

  it 'is not destroyed when the parent is destroyed' do
    expect { parent.destroy }.to_not change(subject, :destroyed?).from(false)
  end
end
