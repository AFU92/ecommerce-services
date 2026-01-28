# frozen_string_literal: true

module Customers
  class OrdersCreatedHandler
    def self.call(payload)
      event_id = payload.fetch("event_id")
      customer_id = payload.dig("order", "customer_id") || payload["customer_id"]
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
