# Customer represents a buyer record in customers service.
# Validates name, address, and non-negative orders_count.
class Customer < ApplicationRecord
  validates :customer_name, presence: true
  validates :address, presence: true
  validates :orders_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
