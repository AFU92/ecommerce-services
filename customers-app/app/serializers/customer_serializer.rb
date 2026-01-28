# frozen_string_literal: true

# Serializes Customer records into JSON:API resource.
# Exposes name, address, and orders_count.
class CustomerSerializer
  include JSONAPI::Serializer

  set_type :customer
  set_id :id

  attributes :customer_name, :address, :orders_count
end
