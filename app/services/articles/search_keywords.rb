module Articles
  class SearchKeywords
    include Callable

    FIELDS = "id,date,slug,title.rendered,excerpt.rendered,jetpack_featured_media_url,categories"
    STATUS = "publish,private"

    KEYWORDS_CATEGORIES = {
      idea: 881417,
      development: 718038516,
      extra_values: 718038291,
      marketing: 15241,
      all: nil
    }.freeze

    ID_TO_CATEGORY_NAMES = KEYWORDS_CATEGORIES.invert.freeze


    CATEGORIES_NAMES = {
      idea: "Idea",
      development: "Development stage",
      extra_values: "Extra values for startups",
      marketing: "Marketing and product related topics",
      all: "All"
    }.freeze

    attr_accessor :search_query,
                  :categories,
                  :page,
                  :per_page,
                  :url,
                  :blog_url

    def initialize(search_query: "",
                   categories: [],
                   page: 1,
                   per_page: 12,
                   url: ENV.fetch("WORDPRESS_BLOG_API_URL"),
                   blog_url: ENV.fetch("WORDPRESS_BLOG_URL")
                  )
      self.search_query = search_query
      self.categories = categories
      self.page = page
      self.per_page = per_page
      self.url = url
      self.blog_url = blog_url
    end

    def call
      response = Net::HTTP.get_response(request_uri)

      parsed_body = JSON.parse(response.body)

      if response.code == "400" and parsed_body["code"] == "rest_post_invalid_page_number"
        return []
      end
      unless response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        raise "WordPress API request failed (#{response.code}): #{response.body}"
      end

      process_response(parsed_body)
    end

    def process_response(parsed_articles)
      parsed_articles.map do |article|
          Article.new(
            id: article["id"],
            title: article["title"]["rendered"],
            excerpt: article["excerpt"]["rendered"],
            wordpress_url: URI.join(self.blog_url, article["slug"]).to_s,
            wordpress_id: article["id"],
            published_at: DateTime.parse(article["date"]),
            categories: article["categories"].map do |category|
              category_key = ID_TO_CATEGORY_NAMES.fetch(category, nil)
              category_name = CATEGORIES_NAMES.fetch(category_key, nil)

              Category.find_or_create_by(
                wordpress_id: category,
                name: category_name
              ) if category_name.present?
            end.compact
          )
      end
    end

    private

    def request_uri
      uri = URI(self.url)
      uri.query = URI.encode_www_form(query_params)
      uri
    end

    def query_params
      params = {
        per_page: per_page,
        page: page,
        status: STATUS,
        _fields: FIELDS,
        search: search_query
      }

      category_ids = resolved_category_ids
      params[:categories] = category_ids.join(",") if category_ids.any?

      params
    end

    def resolved_category_ids
      Array(categories).map { |category| KEYWORDS_CATEGORIES.fetch(category, category) }
    end
  end
end
