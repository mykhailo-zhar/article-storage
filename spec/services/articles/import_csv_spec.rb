require "rails_helper"
require "csv"
require "tempfile"

RSpec.describe Articles::ImportCsv do
  def write_csv(rows)
    Tempfile.create([ "articles", ".csv" ]) do |file|
      CSV.open(file.path, "w", write_headers: true, headers: %w[id title description url category_labels]) do |csv|
        rows.each { |row| csv << row }
      end
      yield file.path
    end
  end

  let(:query_embedding) { Array.new(384) { 0.1 } }
  let(:embedding_model) { double("embedding_model", call: query_embedding) }

  before do
    Articles::SearchSimilar.instance_variable_set(:@embedding_model, embedding_model)
  end

  describe "#call" do
    it "raises when the file does not exist" do
      expect {
        described_class.call(file: "/tmp/missing.csv")
      }.to raise_error(ArgumentError, /CSV file not found/)
    end

    it "imports articles with categories and embeddings" do
      write_csv([
        [ 9, "First post", "First excerpt", "https://example.com/first", "Idea" ],
        [ 14, "Second post", "Second excerpt", "https://example.com/second", "Development stage,Extra values for startups" ]
      ]) do |path|
        result = described_class.call(file: path)

        expect(result.imported_count).to eq(2)
        expect(result.updated_count).to eq(0)

        first = Article.find_by!(wordpress_id: 9)
        expect(first.title).to eq("First post")
        expect(first.excerpt).to eq("First excerpt")
        expect(first.wordpress_url).to eq("https://example.com/first")
        expect(first.embedding.size).to eq(384)
        expect(first.categories.map(&:slug)).to eq([ "idea" ])

        second = Article.find_by!(wordpress_id: 14)
        expect(second.categories.map(&:slug)).to contain_exactly("development", "extra_values")
      end
    end

    it "updates existing articles by wordpress_id" do
      FactoryBot.create(:article, wordpress_id: 9, title: "Old title")

      write_csv([
        [ 9, "Updated title", "Updated excerpt", "https://example.com/updated", "Idea" ]
      ]) do |path|
        result = described_class.call(file: path)

        expect(result.imported_count).to eq(0)
        expect(result.updated_count).to eq(1)
        expect(Article.find_by!(wordpress_id: 9).title).to eq("Updated title")
      end
    end
  end
end
