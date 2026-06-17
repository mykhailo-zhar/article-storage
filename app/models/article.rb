class Article < ApplicationRecord
  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories

  validates :wordpress_id, uniqueness: true, allow_nil: true
end
