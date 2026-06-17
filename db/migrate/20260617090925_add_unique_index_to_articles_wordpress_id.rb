class AddUniqueIndexToArticlesWordpressId < ActiveRecord::Migration[8.1]
  def change
    add_index :articles, :wordpress_id, unique: true
  end
end
