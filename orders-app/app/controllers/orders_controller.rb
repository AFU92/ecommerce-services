# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    customer_id = params[:customer_id]
    if customer_id.blank?
      return render_jsonapi_error(status: :bad_request, title: Constants::BAD_REQUEST, detail: Constants::CUSTOMER_ID_REQUIRED_MSG)
    end

    orders = Order.where(customer_id: customer_id).order(:created_at)
    render json: OrderSerializer.new(orders).serializable_hash
  end

  def create
    order = Orders::CreateOrder.new(params: order_params).call
    render json: OrderSerializer.new(order).serializable_hash, status: :created
  rescue Orders::CreateOrder::CustomerNotFound
    render_jsonapi_error(status: :unprocessable_entity, title: Constants::UNPROCESSABLE, detail: Constants::CUSTOMER_NOT_FOUND_MSG)
  rescue CustomerServiceClient::Unavailable => e
    render_jsonapi_error(status: :bad_gateway, title: Constants::BAD_GATEWAY, detail: e.message)
  rescue OrderCreatedPublisher::PublishError => e
    render_jsonapi_error(status: :internal_server_error, title: Constants::INTERNAL_ERROR, detail: e.message)
  rescue ActiveRecord::RecordInvalid => e
    render_jsonapi_error(status: :unprocessable_entity, title: Constants::UNPROCESSABLE, detail: e.record.errors.full_messages.join(", "))
  end

  private

  def order_params
    container = params[:order] || params
    container = ActionController::Parameters.new(container) unless container.respond_to?(:permit)

    container.permit(:customer_id, :product_name, :quantity, :price, :status).to_h
  end
end
