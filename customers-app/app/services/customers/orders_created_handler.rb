# frozen_string_literal: true

# frozen_string_literal: true

module Customers
  # Handles orders.created events to update customers.
  # Ensures idempotency and increments orders_count.
  class OrdersCreatedHandler
    # Processes event payload and updates counters.
    # Persists ProcessedEvent and logs outcomes.
    #
    # @param payload [Hash] Event data from RabbitMQ.
    # @return [void]
    # @raise [KeyError] when event_id is missing.
    def self.call(payload)
      built = Customers::OrderEventBuilder.build(payload)
      event_id = built[:event_id]
      customer_id = built[:customer_id]
      if customer_id.nil?
        Rails.logger.warn(message: Constants::LOG_ORD_MISSING_CUST, event_id: event_id)
        return
      end

      ProcessedEvent.create!(event_id: event_id, processed_at: Time.current)
      Customer.increment_counter(:orders_count, customer_id)
      Rails.logger.info(message: Constants::LOG_ORD_PROCESSED, event_id: event_id, customer_id: customer_id)
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info(message: Constants::LOG_ORD_ALREADY, event_id: event_id)
      nil
    end
  end
end
