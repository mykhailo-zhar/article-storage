require "csv"

module Articles
  class ImportCsv
    include Callable

    CATEGORY_NAME_TO_SLUG = SearchKeywords::CATEGORIES_NAMES.except(:all).invert.transform_values(&:to_s).freeze

    attr_reader :file, :imported_count, :updated_count

    def initialize(file:)
      @file = Pathname.new(file)
      @imported_count = 0
      @updated_count = 0
    end

    def call
      raise ArgumentError, "CSV file not found: #{file}" unless file.file?

      CSV.foreach(file, headers: true) do |row|
        import_row(row)
      end

      self
    end

    private

    def import_row(row)
      article = Article.find_or_initialize_by(wordpress_id: row["id"].to_i)
      new_record = article.new_record?

      article.assign_attributes(
        title: row["title"],
        excerpt: row["description"],
        wordpress_url: row["url"]
      )
      article.save!
      article.categories = categories_for(row["category_labels"])
      article.update!(embedding: embed(article))

      if new_record
        @imported_count += 1
      else
        @updated_count += 1
      end
    end

    def categories_for(category_labels)
      category_labels.to_s.split(",").map(&:strip).reject(&:blank?).map do |name|
        slug = CATEGORY_NAME_TO_SLUG.fetch(name) { name.parameterize(separator: "_") }
        Category.find_or_create_by!(name: name) { |category| category.slug = slug }
      end
    end

    def embed(article)
      text = [ article.title, article.excerpt ].compact.join("\n\n")
      embedding_model.(text)
    end

    def embedding_model
      SearchSimilar.embedding_model
    end
  end
end
