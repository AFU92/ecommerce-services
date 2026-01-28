# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    customer_id { Faker::Number.between(from: 1, to: 10_000) }
    product_name { Faker::Commerce.product_name }
    quantity { Faker::Number.between(from: 1, to: 5) }
    price { Faker::Commerce.price(range: 1.0..500.0) }
    status { "created" }
  end
end
