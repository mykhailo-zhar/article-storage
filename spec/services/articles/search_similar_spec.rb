require "rails_helper"

RSpec.describe Articles::SearchSimilar do
  let(:service) do
    described_class.new(
      search_query: "MVP",
      categories: [ :idea ],
      page: 2,
      per_page: 10
    )
  end

  describe ".call" do
    it "returns an empty array" do
      expect(described_class.call(search_query: "MVP")).to eq([])
    end
  end

  describe "#call" do
    it "returns an empty array" do
      expect(service.call).to eq([])
    end
  end

  describe "#initialize" do
    it "accepts search_query, categories, page, and per_page" do
      expect(service.search_query).to eq("MVP")
      expect(service.categories).to eq([ :idea ])
      expect(service.page).to eq(2)
      expect(service.per_page).to eq(10)
    end
  end

  describe "#resolved_categories" do
    it "returns Category.none when categories are empty" do
      service = described_class.new(categories: [])

      expect(service.send(:resolved_categories)).to eq(Category.none)
    end

    it "returns Category.none when only :all is selected" do
      service = described_class.new(categories: [ :all ])

      expect(service.send(:resolved_categories)).to eq(Category.none)
    end

    it "returns matching Category records when slugs exist in the DB" do
      idea = FactoryBot.create(:category, slug: "idea", name: "Idea")
      FactoryBot.create(:category, slug: "marketing", name: "Marketing")
      service = described_class.new(categories: [ :idea, :marketing ])

      expect(service.send(:resolved_categories)).to contain_exactly(idea, Category.find_by!(slug: "marketing"))
    end
  end
end
