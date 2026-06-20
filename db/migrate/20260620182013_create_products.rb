class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.integer :compare_at_price_cents
      t.references :category, null: true, foreign_key: true
      t.boolean :in_stock, default: true
      t.boolean :featured, default: false
      t.integer :position, default: 0
      t.string :meta_title
      t.string :meta_description
      t.string :meta_keywords
      t.string :og_image_url

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :in_stock
    add_index :products, :featured
  end
end
