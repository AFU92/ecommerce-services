# frozen_string_literal: true

# Serializes Order into JSON:API resource.
# Emits price as string and ISO created_at.
class OrderSerializer
  include JSONAPI::Serializer

  set_type :order
  set_id :id

  attributes :customer_id, :product_name, :quantity, :status

  attribute :price do |order|
    order.price.to_s
  end

  attribute :created_at do |order|
    order.created_at&.iso8601
  end
end
