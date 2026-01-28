# frozen_string_literal: true

# Builds the orders.created event payload consistently.
# Centralizes shape and formatting for the event data.
class OrderEventBuilder
  # Returns the event payload for an order.
  #
  # @param order [Order] The order being published.
  # @param event_id [String] Optional id for the event.
  # @return [Hash] Event payload with event_id and order fields.
  def self.build(order, event_id: SecureRandom.uuid)
    {
      event_id: event_id,
      order: {
        id: order.id,
        customer_id: order.customer_id,
        product_name: order.product_name,
        quantity: order.quantity,
        price: order.price.to_s,
        status: order.status,
        created_at: order.created_at&.iso8601
      }
    }
  end
end

