# frozen_string_literal: true

module Customers
  class OrdersCreatedHandler
    def self.call(payload)
      event_id = payload.fetch("event_id")
      customer_id = payload.dig("order", "customer_id") || payload["customer_id"]
      return if customer_id.nil?

      ProcessedEvent.create!(event_id: event_id, processed_at: Time.current)
      Customer.increment_counter(:orders_count, customer_id)
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end
