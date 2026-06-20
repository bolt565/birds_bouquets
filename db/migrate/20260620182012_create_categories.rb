class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.string :meta_description
      t.string :meta_keywords

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
