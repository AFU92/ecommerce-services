# frozen_string_literal: true

module Customers
  # Builds a normalized view of an orders.created payload.
  # Extracts event_id and customer_id consistently.
  class OrderEventBuilder
    # @param payload [Hash] Raw event payload from RabbitMQ.
    # @return [Hash] { event_id:, customer_id: }
    # @raise [KeyError] when event_id is missing.
    def self.build(payload)
      event_id = payload.fetch("event_id")
      customer_id = payload.dig("order", "customer_id") || payload["customer_id"]
      { event_id: event_id, customer_id: customer_id }
    end
  end
end
