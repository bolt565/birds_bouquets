class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: true, foreign_key: true
      t.string :order_number, null: false
      t.string :status, null: false, default: "pending"
      t.string :email, null: false
      t.string :phone
      t.integer :subtotal_cents, null: false
      t.integer :shipping_cents, null: false, default: 0
      t.integer :tax_cents, null: false, default: 0
      t.integer :total_cents, null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_charge_id
      t.string :shipping_name, null: false
      t.string :shipping_line1, null: false
      t.string :shipping_line2
      t.string :shipping_city, null: false
      t.string :shipping_state, null: false
      t.string :shipping_zip, null: false
      t.string :shipping_country, null: false, default: "US"
      t.string :tracking_number
      t.text :notes
      t.text :admin_notes
      t.datetime :paid_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :cancelled_at
      t.string :cancellation_reason

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :email
  end
end
