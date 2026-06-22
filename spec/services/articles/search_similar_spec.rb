require "rails_helper"

RSpec.describe Articles::SearchSimilar do
  def unit_vector(index)
    Array.new(384) { |i| i == index ? 1.0 : 0.0 }
  end

  describe "#call" do
    let(:query_embedding) { unit_vector(0) }
    let(:embedding_model) { double("embedding_model", call: query_embedding) }

    before do
      stub_const("Articles::SearchSimilar::MIN_SIMILARITY_SCORE", 0)
      described_class.instance_variable_set(:@embedding_model, embedding_model)
    end

    it "returns an empty array when search_query is blank" do
      service = described_class.new(search_query: "")

      result = service.call

      expect(result[:articles]).to eq([])
      expect(result[:total_pages]).to eq(0)
    end

    it "returns persisted articles with categories loaded" do
      category = FactoryBot.create(:category, slug: "idea", name: "Idea")
      article = FactoryBot.create(:article, embedding: unit_vector(0), categories: [ category ])

      result = described_class.new(search_query: "MVP").call

      first_article = result[:articles].first

      expect(result[:articles]).to eq([ article ])
      expect(first_article.association(:categories)).to be_loaded
      expect(first_article.categories).to contain_exactly(category)
      expect(result[:total_pages]).to eq(1)
    end

    it "orders results by cosine similarity" do
      closest = FactoryBot.create(:article, title: "Closest", embedding: unit_vector(0))
      middle = FactoryBot.create(:article, title: "Middle", embedding: unit_vector(1))
      farthest = FactoryBot.create(:article, title: "Farthest", embedding: unit_vector(2))

      result = described_class.new(search_query: "MVP").call

      expect(result[:articles]).to eq([ closest, middle, farthest ])
      expect(result[:total_pages]).to eq(1)
    end

    it "filters by category id" do
      idea = FactoryBot.create(:category, slug: "idea", name: "Idea")
      marketing = FactoryBot.create(:category, slug: "marketing", name: "Marketing")
      idea_article = FactoryBot.create(:article, title: "Idea article", embedding: unit_vector(0), categories: [ idea ])
      FactoryBot.create(:article, title: "Marketing article", embedding: unit_vector(1), categories: [ marketing ])

      result = described_class.new(search_query: "MVP", categories: [ idea.id ]).call

      expect(result[:articles]).to eq([ idea_article ])
      expect(result[:total_pages]).to eq(1)
    end

    it "respects page and per_page" do
      first = FactoryBot.create(:article, title: "First", embedding: unit_vector(0))
      second = FactoryBot.create(:article, title: "Second", embedding: unit_vector(1))
      FactoryBot.create(:article, title: "Third", embedding: unit_vector(2))

      result = described_class.new(search_query: "MVP", page: 2, per_page: 1).call

      expect(result[:articles]).to eq([ second ])
      expect(result[:articles]).not_to include(first)
      expect(result[:total_pages]).to eq(3)
    end

    it "embeds the search query" do
      described_class.new(search_query: "MVP").call

      expect(embedding_model).to have_received(:call).with("MVP")
    end
  end

  describe ".call" do
    it "returns an empty array when search_query is blank" do
      expect(described_class.call(search_query: "")[:articles]).to eq([])
      expect(described_class.call(search_query: "")[:total_pages]).to eq(0)
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
end
