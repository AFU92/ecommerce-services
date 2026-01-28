# frozen_string_literal: true

module Orders
  class CreateOrder
    class CustomerNotFound < StandardError; end

    def initialize(params:)
      @params = params.symbolize_keys
    end

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

    def ensure_customer_exists!(customer_id)
      raise ArgumentError, "customer_id is required" if customer_id.blank?

      CustomerServiceClient.new.ensure_exists!(customer_id)
    end
  end
end

