class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.integer :customer_id, null: false
      t.string :product_name, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :price, null: false, precision: 12, scale: 2
      t.string :status, null: false, default: "created"

      t.timestamps
    end
  end
end
