# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class CustomerServiceClient
  class Unavailable < StandardError; end

  def initialize(base_url: ENV.fetch('CUSTOMER_SERVICE_URL', 'http://customer-service:3001'))
    @base_url = base_url
  end

  def ensure_exists!(customer_id)
    uri = URI.join(@base_url.end_with?('/') ? @base_url : @base_url + '/', "customers/#{customer_id}")
    req = Net::HTTP::Get.new(uri)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 5
    http.open_timeout = 2

    res = http.request(req)

    case res.code.to_i
    when 200
      true
    when 404
      raise Orders::CreateOrder::CustomerNotFound
    else
      raise Unavailable, "Customers Service returned #{res.code}"
    end
  rescue SocketError, IOError, SystemCallError, Timeout::Error => e
    raise Unavailable, e.message
  end
end

