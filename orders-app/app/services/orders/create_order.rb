# frozen_string_literal: true

module Orders
  # Creates an Order after checking customer exists.
  # Emits an orders.created event after persistence.
  class CreateOrder
    class CustomerNotFound < StandardError; end

    def initialize(params:)
      @params = params.symbolize_keys
    end

    # Persists a new order and publishes an event.
    # Validates customer via HTTP before persisting.
    #
    # @return [Order] The persisted order.
    # @raise [Orders::CreateOrder::CustomerNotFound] when customer is missing.
    # @raise [CustomerServiceClient::Unavailable] when customer service fails.
    # @raise [OrderCreatedPublisher::PublishError] when publishing fails.
    # @raise [ActiveRecord::RecordInvalid] when validation fails.
    def call
      ensure_customer_exists!(@params[:customer_id])

      order = Order.create!(
        customer_id: @params[:customer_id],
        product_name: @params[:product_name],
        quantity: @params[:quantity],
        price: @params[:price],
        status: @params[:status]
      )

      OrderCreatedPublisher.new(order).publish!

      order
    end

    private

    # Ensures customer exists using the Customers service.
    #
    # @param customer_id [Integer] Customer identifier.
    # @raise [ArgumentError] when customer_id is blank.
    def ensure_customer_exists!(customer_id)
      raise ArgumentError, ::Constants::CUSTOMER_ID_REQUIRED_MSG if customer_id.blank?

      CustomerServiceClient.new.ensure_exists!(customer_id)
    end
  end
end
