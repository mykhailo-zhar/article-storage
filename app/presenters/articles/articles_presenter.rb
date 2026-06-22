module Articles
  class ArticlesPresenter
    attr_reader :articles,
      :search_query,
      :type,
      :selected_categories,
      :page,
      :total_pages,
      :context

    def initialize(articles:, search_query:, type:, selected_categories:, page:, total_pages:, context:)
      @articles = articles
      @search_query = search_query
      @type = type
      @selected_categories = selected_categories
      @page = page
      @total_pages = total_pages
      @context = context
    end

    def no_articles?
      articles.empty? && context.flash[:alert].blank?
    end

    def navigation_enabled?
      page > 1 || (total_pages.present? && total_pages > page)
    end

    def previous_page_enabled?
      page > 1
    end

    def next_page_enabled?
      total_pages.present? && total_pages > page
    end

    def previous_page_url
      context.articles_path(search: search_query, categories: selected_categories, page: page - 1, type: type)
    end

    def next_page_url
      context.articles_path(search: search_query, categories: selected_categories, page: page + 1, type: type)
    end

    def categories
      Articles::SearchKeywords::CATEGORIES_NAMES
    end
  end
end
