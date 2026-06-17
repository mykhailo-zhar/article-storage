class Category < ApplicationRecord
  belongs_to :parent,
    class_name: "Category",
    optional: true

  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories
end
