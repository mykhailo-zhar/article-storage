# == Schema Information
#
# Table name: articles
#
#  id            :integer          not null, primary key
#  excerpt       :text
#  published_at  :datetime
#  title         :string
#  wordpress_url :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  wordpress_id  :integer
#
# Indexes
#
#  index_articles_on_wordpress_id  (wordpress_id) UNIQUE
#
class Article < ApplicationRecord
  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories

  validates :wordpress_id, uniqueness: true, allow_nil: true
  validate :wordpress_url_must_be_safe_external, if: -> { wordpress_url.present? }

  private

  def wordpress_url_must_be_safe_external
    return if UriSanitizerHelper.safe_external_url(wordpress_url).present?

    errors.add(:wordpress_url, "must be a valid http or https URL")
  end
end
