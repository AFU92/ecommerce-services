# frozen_string_literal: true

module WebmockHelpers
  def stub_customer_ok(id: 1, name: "Ana", address: "Street", orders_count: 0)
    stub_request(:get, %r{/customers/#{id}})
      .to_return(
        status: 200,
        body: {
          data: {
            id: id.to_s,
            type: "customer",
            attributes: { customer_name: name, address: address, orders_count: orders_count }
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_customer_not_found(id: 999)
    stub_request(:get, %r{/customers/#{id}})
      .to_return(status: 404, body: "", headers: {})
  end
end

RSpec.configure do |config|
  config.include WebmockHelpers, type: :request
end

