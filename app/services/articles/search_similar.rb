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
      return [] if search_query.blank?

      query_embedding = embed(search_query)
      articles = articles_scope
        .includes(:categories)

      articles = articles.where(categories: { slug: categories }) if categories.present?

      @total_pages = (articles.count / per_page).ceil

      articles.nearest_neighbors(:embedding, query_embedding, distance: "cosine")
        .limit(per_page)
        .offset(offset)
        .to_a
    end

    private

    def embed(text)
      embedding_model.(text)
    end

    def embedding_model
      self.class.embedding_model
    end

    def articles_scope
      scope = Article.where.not(embedding: nil)
      categories = resolved_categories

      if categories.exists?
        scope = scope.joins(:article_categories)
          .where(article_categories: { category_id: categories.select(:id) })
          .distinct
      end

      scope
    end

    def offset
      (page - 1) * per_page
    end

    def resolved_categories
      slugs = Array(categories).map(&:to_s).reject { |slug| slug == "all" }
      return Category.none if slugs.empty?

      Category.where(slug: slugs)
    end

    class << self
      def embedding_model
        @embedding_model ||= Informers.pipeline("embedding", EMBEDDING_MODEL)
      end
    end
  end
end
