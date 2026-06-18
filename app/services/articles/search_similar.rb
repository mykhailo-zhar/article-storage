module Articles
  class SearchSimilar
    include Callable

    attr_accessor :search_query, :categories, :page, :per_page
    attr_reader :total_pages

    def initialize(search_query: "", categories: [], page: 1, per_page: 12)
      self.search_query = search_query
      self.categories = categories
      self.page = page
      self.per_page = per_page
    end

    def call
      # TODO: embed search_query, run Article.nearest_neighbors, filter by resolved_categories, paginate
      []
    end

    private

    def resolved_categories
      slugs = Array(categories).map(&:to_s).reject { |slug| slug == "all" }
      return Category.none if slugs.empty?

      Category.where(slug: slugs)
    end
  end
end
