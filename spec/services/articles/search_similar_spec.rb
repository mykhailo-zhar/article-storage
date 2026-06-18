require "rails_helper"

RSpec.describe Articles::SearchSimilar do
  def unit_vector(index)
    Array.new(384) { |i| i == index ? 1.0 : 0.0 }
  end

  describe "#call" do
    let(:query_embedding) { unit_vector(0) }
    let(:embedding_model) { double("embedding_model", call: query_embedding) }

    before do
      described_class.instance_variable_set(:@embedding_model, embedding_model)
    end

    it "returns an empty array when search_query is blank" do
      service = described_class.new(search_query: "")

      expect(service.call).to eq([])
    end

    it "returns persisted articles with categories loaded" do
      category = FactoryBot.create(:category, slug: "idea", name: "Idea")
      article = FactoryBot.create(:article, embedding: unit_vector(0), categories: [ category ])

      result = described_class.new(search_query: "MVP").call

      expect(result).to eq([ article ])
      expect(result.first.association(:categories)).to be_loaded
      expect(result.first.categories).to contain_exactly(category)
    end

    it "orders results by cosine similarity" do
      closest = FactoryBot.create(:article, title: "Closest", embedding: unit_vector(0))
      middle = FactoryBot.create(:article, title: "Middle", embedding: unit_vector(1))
      farthest = FactoryBot.create(:article, title: "Farthest", embedding: unit_vector(2))

      result = described_class.new(search_query: "MVP").call

      expect(result).to eq([ closest, middle, farthest ])
    end

    it "filters by category slug" do
      idea = FactoryBot.create(:category, slug: "idea", name: "Idea")
      marketing = FactoryBot.create(:category, slug: "marketing", name: "Marketing")
      idea_article = FactoryBot.create(:article, title: "Idea article", embedding: unit_vector(0), categories: [ idea ])
      FactoryBot.create(:article, title: "Marketing article", embedding: unit_vector(1), categories: [ marketing ])

      result = described_class.new(search_query: "MVP", categories: [ :idea ]).call

      expect(result).to eq([ idea_article ])
    end

    it "respects page and per_page" do
      first = FactoryBot.create(:article, title: "First", embedding: unit_vector(0))
      second = FactoryBot.create(:article, title: "Second", embedding: unit_vector(1))
      FactoryBot.create(:article, title: "Third", embedding: unit_vector(2))

      result = described_class.new(search_query: "MVP", page: 2, per_page: 1).call

      expect(result).to eq([ second ])
      expect(result).not_to include(first)
    end

    it "embeds the search query" do
      described_class.new(search_query: "MVP").call

      expect(embedding_model).to have_received(:call).with("MVP")
    end
  end

  describe ".call" do
    it "returns an empty array when search_query is blank" do
      expect(described_class.call(search_query: "")).to eq([])
    end
  end

  describe "#initialize" do
    it "accepts search_query, categories, page, and per_page" do
      service = described_class.new(
        search_query: "MVP",
        categories: [ :idea ],
        page: 2,
        per_page: 10
      )

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
