class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.string :product_name, null: false

      t.timestamps
    end
  end
end
