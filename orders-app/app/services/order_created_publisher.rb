# frozen_string_literal: true

require 'bunny'
require 'json'
require_relative '../constants'

class OrderCreatedPublisher
  class PublishError < StandardError; end

  EXCHANGE = Constants::ORDERS_EXCHANGE
  ROUTING_KEY = Constants::ORDERS_CREATED_KEY

  def initialize(order)
    @order = order
  end

  def publish!
    event_id = SecureRandom.uuid
    conn = Bunny.new(ENV.fetch('RABBITMQ_URL'))
    conn.start
    ch = conn.create_channel
    exchange = ch.direct(EXCHANGE, durable: true)

    payload = {
      event_id: event_id,
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
    Rails.logger.info(message: Constants::LOG_PUB_START, event_id: event_id, order_id: @order.id, customer_id: @order.customer_id)
    exchange.publish(payload.to_json, routing_key: ROUTING_KEY, content_type: 'application/json', persistent: true)
    Rails.logger.info(message: Constants::LOG_PUB_OK, event_id: event_id, order_id: @order.id)
    ch.close
    conn.close
    true
  rescue StandardError => e
    Rails.logger.error(message: Constants::LOG_PUB_ERR, error: e.class.name, detail: e.message, order_id: @order&.id)
    raise PublishError, e.message
  end
end
