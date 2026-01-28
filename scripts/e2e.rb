# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

ORDERS_BASE = ENV.fetch('ORDERS_BASE', 'http://localhost:3000')
CUSTOMERS_BASE = ENV.fetch('CUSTOMERS_BASE', 'http://localhost:3001')

def http_get(url)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri)
  Net::HTTP.start(uri.host, uri.port, read_timeout: 5, open_timeout: 2) do |http|
    http.request(req)
  end
end

def http_post_json(url, body_hash)
  uri = URI(url)
  req = Net::HTTP::Post.new(uri)
  req['Content-Type'] = 'application/json'
  req.body = JSON.dump(body_hash)
  Net::HTTP.start(uri.host, uri.port, read_timeout: 5, open_timeout: 2) do |http|
    http.request(req)
  end
end

def wait_until(msg, timeout: 60)
  deadline = Time.now + timeout
  loop do
    begin
      return true if yield
    rescue StandardError
      # ignore and retry
    end
    raise "Timeout waiting for #{msg}" if Time.now > deadline
    sleep 1
  end
end

def parse_json(res)
  JSON.parse(res.body)
rescue JSON::ParserError
  {}
end

def log(line)
  puts "[e2e] #{line}"
end

log "Waiting for services to be up (/up)"
wait_until('customers /up') { http_get("#{CUSTOMERS_BASE}/up").is_a?(Net::HTTPSuccess) }
wait_until('orders /up')    { http_get("#{ORDERS_BASE}/up").is_a?(Net::HTTPSuccess) }

customer_id = (ENV['E2E_CUSTOMER_ID'] || '1').to_i

log "Fetching customer ##{customer_id}"
res = http_get("#{CUSTOMERS_BASE}/customers/#{customer_id}")
if res.code.to_i == 404
  abort "Customer ##{customer_id} not found. Are seeds loaded?"
end
raise "Unexpected response from Customers: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

before = parse_json(res).dig('data', 'attributes', 'orders_count').to_i
log "Current orders_count=#{before}"

order_payload = {
  customer_id: customer_id,
  product_name: "E2E Keyboard",
  quantity: 1,
  price: "123.45",
  status: "created"
}

log "POST /orders"
res = http_post_json("#{ORDERS_BASE}/orders", order_payload)
raise "Order creation failed: #{res.code} #{res.body}" unless res.code.to_i == 201

log "Waiting for customers consumer to increment orders_count"
wait_until('orders_count incremented', timeout: 60) do
  r = http_get("#{CUSTOMERS_BASE}/customers/#{customer_id}")
  next false unless r.is_a?(Net::HTTPSuccess)
  now = parse_json(r).dig('data', 'attributes', 'orders_count').to_i
  now >= before + 1
end

log "Verifying orders list by customer_id"
res = http_get("#{ORDERS_BASE}/orders?customer_id=#{customer_id}")
raise "Orders query failed: #{res.code}" unless res.is_a?(Net::HTTPSuccess)
data = parse_json(res)['data'] || []
raise "Orders list empty" if data.empty?

log "E2E passed: created order, event processed, count incremented"

