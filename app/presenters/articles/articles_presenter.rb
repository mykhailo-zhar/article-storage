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

    def selected_categories_params
      selected_categories.map { |parent, categories| [ "categories_#{parent}", categories.to_a ] }.to_h
    end

    def previous_page_url
      context.articles_path(search: search_query, categories: selected_categories_params, page: page - 1, type: type)
    end

    def next_page_url
      context.articles_path(search: search_query, **selected_categories_params, page: page + 1, type: type)
    end

    def categories
      case type
      when :keywords
        keywords_categories
      when :similar
        similar_categories
      end
    end

    private

    def keywords_categories
      Category.for_search_keywords.all.group_by(&:parent)
    end

    def similar_categories
      Category.for_search_similar.all.group_by(&:parent)
    end
  end
end
