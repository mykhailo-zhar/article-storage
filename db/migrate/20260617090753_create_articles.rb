class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :excerpt
      t.string :wordpress_url
      t.integer :wordpress_id
      t.datetime :published_at

      t.timestamps
    end
  end
end
