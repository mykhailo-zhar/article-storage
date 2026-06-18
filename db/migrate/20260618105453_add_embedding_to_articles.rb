class AddEmbeddingToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :embedding, :binary, limit: 384
  end
end
