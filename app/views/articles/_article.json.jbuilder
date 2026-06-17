json.extract! article, :id, :title, :excerpt, :wordpress_url, :wordpress_id, :published_at, :created_at, :updated_at
json.categories article.categories, :id, :name, :slug
json.url article_url(article, format: :json)
