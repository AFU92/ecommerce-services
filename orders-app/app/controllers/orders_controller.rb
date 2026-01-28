# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    customer_id = params[:customer_id]
    if customer_id.blank?
      Rails.logger.warn(message: Constants::LOG_MISSING_CUST_ID)
      return render_jsonapi_error(status: :bad_request, title: Constants::BAD_REQUEST, detail: Constants::CUSTOMER_ID_REQUIRED_MSG)
    end

    orders = Order.where(customer_id: customer_id).order(:created_at)
    render json: OrderSerializer.new(orders).serializable_hash
  end

  def create
    order = Orders::CreateOrder.new(params: order_params).call
    render json: OrderSerializer.new(order).serializable_hash, status: :created
  rescue Orders::CreateOrder::CustomerNotFound
    Rails.logger.warn(message: Constants::LOG_REJECT_CUST, customer_id: order_params[:customer_id])
    render_jsonapi_error(status: :unprocessable_entity, title: Constants::UNPROCESSABLE, detail: Constants::CUSTOMER_NOT_FOUND_MSG)
  rescue CustomerServiceClient::Unavailable => e
    Rails.logger.error(message: Constants::LOG_CUST_SVC_DOWN, customer_id: order_params[:customer_id], error: e.class.name, detail: e.message)
    render_jsonapi_error(status: :bad_gateway, title: Constants::BAD_GATEWAY, detail: e.message)
  rescue OrderCreatedPublisher::PublishError => e
    Rails.logger.error(message: Constants::LOG_PUB_FAIL, error: e.class.name, detail: e.message)
    render_jsonapi_error(status: :internal_server_error, title: Constants::INTERNAL_ERROR, detail: e.message)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn(message: Constants::LOG_INVALID, errors: e.record.errors.full_messages)
    render_jsonapi_error(status: :unprocessable_entity, title: Constants::UNPROCESSABLE, detail: e.record.errors.full_messages.join(", "))
  end

  private

  def order_params
    container = params[:order] || params
    container = ActionController::Parameters.new(container) unless container.respond_to?(:permit)

    container.permit(:customer_id, :product_name, :quantity, :price, :status).to_h
  end
end
