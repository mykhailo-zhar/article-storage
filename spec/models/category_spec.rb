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
