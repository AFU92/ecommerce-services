class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :customer_name, null: false
      t.string :address, null: false
      t.integer :orders_count, null: false, default: 0

      t.timestamps
    end
  end
end
