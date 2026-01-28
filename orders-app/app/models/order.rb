# Order represents a purchase placed by a customer.
# Validates product, quantity, price, and status.
class Order < ApplicationRecord
  validates :customer_id, presence: true
  validates :product_name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
end
