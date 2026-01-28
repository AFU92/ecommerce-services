# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

# Simple HTTP client for the Customers service.
# Verifies customer existence for order creation.
class CustomerServiceClient
  class Unavailable < StandardError; end

  def initialize(base_url: ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer-service:3001"))
    @base_url = base_url
  end

  # Checks if customer exists via HTTP GET.
  # Logs outcomes and maps errors to exceptions.
  #
  # @param customer_id [Integer] Customer identifier.
  # @return [true] when the customer exists.
  # @raise [Orders::CreateOrder::CustomerNotFound] when service returns 404.
  # @raise [CustomerServiceClient::Unavailable] on network or unexpected responses.
  def ensure_exists!(customer_id)
    uri = URI.join(@base_url.end_with?("/") ? @base_url : @base_url + "/", "customers/#{customer_id}")
    req = Net::HTTP::Get.new(uri)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 5
    http.open_timeout = 2

    response = http.request(req)

    case response.code.to_i
    when 200
      true
    when 404
      Rails.logger.warn(message: Constants::LOG_CUST_NOT_FOUND, customer_id: customer_id)
      raise Orders::CreateOrder::CustomerNotFound
    else
      Rails.logger.error(message: Constants::LOG_CUST_SVC_BAD_STATUS, status: response.code, customer_id: customer_id)
      raise Unavailable, "#{Constants::CUST_SVC_RETURNED} #{response.code}"
    end
  rescue SocketError, IOError, SystemCallError, Timeout::Error => e
    Rails.logger.error(message: Constants::LOG_CUST_SVC_UNAVAILABLE, error: e.class.name, detail: e.message, customer_id: customer_id)
    raise Unavailable, e.message
  end
end
