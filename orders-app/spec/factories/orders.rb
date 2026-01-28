# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    customer_id { 1 }
    product_name { "Keyboard" }
    quantity { 1 }
    price { 9.99 }
    status { "created" }
  end
end
