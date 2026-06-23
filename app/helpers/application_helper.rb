module ApplicationHelper
  SEARCH_NAV_TYPES = {
    keywords: "Keywords",
    similar: "Similarity"
  }.freeze

  def search_nav_path(type)
    case type
    when :keywords
      keywords_articles_path
    when :similar
      similar_articles_path
    end
  end

  def search_nav_active?(type)
    controller_name == "articles" && action_name == "index" &&
      (params[:type]&.to_sym || :keywords) == type
  end

  def search_nav_link_class(type)
    classes = [ "site-nav__link" ]
    classes << "site-nav__link--active" if search_nav_active?(type)
    classes.join(" ")
  end
end
