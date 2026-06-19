module Articles
  class SearchFactory
    include Callable


    attr_accessor :search_query, :categories, :page, :per_page, :type


    def initialize(search_query: "", categories: [], page: 1, per_page: 12, type: :keywords)
      self.search_query = search_query
      self.categories = categories
      self.page = page
      self.per_page = per_page
      self.type = type
    end

    def call
      service = service_for(type)

      result = service.call
      result
    end

    private

    def service_for(type)
      case type
      when :keywords
        SearchKeywords.new(search_query: search_query, categories: categories, page: page, per_page: per_page)
      when :similar
        SearchSimilar.new(search_query: search_query, categories: categories, page: page, per_page: per_page)
      else
        raise "Invalid search type: #{type}"
      end
    end
  end
end
