# frozen_string_literal: true

require 'bunny'
require 'json'

class OrderCreatedPublisher
  class PublishError < StandardError; end

  EXCHANGE = AppConstants::EXCHANGE_ORDERS_EVENTS
  ROUTING_KEY = AppConstants::ROUTING_KEY_ORDERS_CREATED

  def initialize(order)
    @order = order
  end

  def publish!
    conn = Bunny.new(ENV.fetch('RABBITMQ_URL'))
    conn.start
    ch = conn.create_channel
    exchange = ch.direct(EXCHANGE, durable: true)

    payload = {
      event_id: SecureRandom.uuid,
      order: {
        id: @order.id,
        customer_id: @order.customer_id,
        product_name: @order.product_name,
        quantity: @order.quantity,
        price: @order.price.to_s,
        status: @order.status,
        created_at: @order.created_at&.iso8601
      }
    }

    exchange.publish(payload.to_json, routing_key: ROUTING_KEY, content_type: 'application/json', persistent: true)
    ch.close
    conn.close
    true
  rescue StandardError => e
    raise PublishError, e.message
  end
end
