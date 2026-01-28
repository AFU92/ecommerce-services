# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    customer_name { "John Doe" }
    address { "123 Main St" }
    orders_count { 0 }
  end
end

