class AddDescriptionToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :description, :text
  end
end
