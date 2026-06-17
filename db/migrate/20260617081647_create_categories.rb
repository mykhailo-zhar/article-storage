class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.references :parent, foreign_key: { to_table: :categories, on_delete: :nullify, on_update: :cascade }
      t.integer :wordpress_id

      t.timestamps
    end
  end
end
