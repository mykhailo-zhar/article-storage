module Articles
  class SearchSimilar
    include Callable

    EMBEDDING_MODEL = "sentence-transformers/all-MiniLM-L6-v2"

    attr_accessor :search_query, :categories, :page, :per_page
    attr_reader :total_pages

    def initialize(search_query: "", categories: [], page: 1, per_page: 12)
      self.search_query = search_query
      self.categories = categories
      self.page = page
      self.per_page = per_page
    end

    def call
      query_embedding = embed(search_query)

      articles = articles_scope
        .includes(:categories)

      resolved_categories = categories&.map(&:to_s)&.reject { |slug| slug == "all" }
      articles = articles.where(categories: { slug: resolved_categories }) if resolved_categories.any?

      articles = articles.nearest_neighbors(:embedding, query_embedding, distance: "cosine") if query_embedding.present?

      articles_result = articles
        .limit(per_page)
        .offset(offset)
        .to_a
      {
        articles: articles_result,
        total_pages: (articles_result.count / per_page.to_f).ceil
      }
    end

    private

    def embed(text)
      return nil if text.blank?
      embedding_model.(text)
    end

    def embedding_model
      self.class.embedding_model
    end

    def articles_scope
      scope = Article.where.not(embedding: nil)

      scope
    end

    def offset
      (page - 1) * per_page
    end

    class << self
      def embedding_model
        @embedding_model ||= Informers.pipeline("embedding", EMBEDDING_MODEL)
      end
    end
  end
end
