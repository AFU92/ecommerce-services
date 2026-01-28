# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    customer_id = params[:customer_id]
    if customer_id.blank?
      return render_jsonapi_error(status: :bad_request, title: "Bad Request", detail: "customer_id is required")
    end

    orders = Order.where(customer_id: customer_id).order(:created_at)
    render json: OrderSerializer.new(orders).serializable_hash
  end

  def create
    order = Orders::CreateOrder.new(params: order_params).call
    render json: OrderSerializer.new(order).serializable_hash, status: :created
  rescue Orders::CreateOrder::CustomerNotFound
    render_jsonapi_error(status: :unprocessable_entity, title: "Unprocessable Entity", detail: "Customer not found")
  rescue CustomerServiceClient::Unavailable => e
    render_jsonapi_error(status: :bad_gateway, title: "Bad Gateway", detail: e.message)
  rescue OrderCreatedPublisher::PublishError => e
    render_jsonapi_error(status: :internal_server_error, title: "Internal Server Error", detail: e.message)
  rescue ActiveRecord::RecordInvalid => e
    render_jsonapi_error(status: :unprocessable_entity, title: "Unprocessable Entity", detail: e.record.errors.full_messages.join(", "))
  end

  private

  def order_params
    container = params[:order] || params
    container = ActionController::Parameters.new(container) unless container.respond_to?(:permit)

    container.permit(:customer_id, :product_name, :quantity, :price, :status).to_h
  end
end

