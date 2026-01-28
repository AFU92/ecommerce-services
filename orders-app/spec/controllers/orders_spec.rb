# frozen_string_literal: true

# Request specs for listing and creating orders.
# Stubs customer service and event publishing.
require "rails_helper"

RSpec.describe "Orders", type: :request do
  before do
    # Avoid using real RabbitMQ in specs
    allow_any_instance_of(OrderCreatedPublisher).to receive(:publish!).and_return(true)
  end

  describe "POST /orders" do
    it "creates an order after validating customer via HTTP" do
      stub_customer_ok(id: 1)

      post "/orders", params: { customer_id: 1, product_name: "Keyboard", quantity: 2, price: "99.90", status: "created" }

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["type"]).to eq("order")
      expect(json_body["data"]["attributes"]["customer_id"]).to eq(1)
      expect(json_body["data"]["attributes"]["product_name"]).to eq("Keyboard")
    end

    it "returns 422 when customer does not exist" do
      stub_customer_not_found(id: 999)

      post "/orders", params: { customer_id: 999, product_name: "Mouse", quantity: 1, price: "10.00", status: "created" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_body["errors"][0]["status"]).to eq("422")
    end
  end

  describe "GET /orders?customer_id=1" do
    it "lists orders for a customer" do
      create(:order, customer_id: 1, product_name: "A", quantity: 1, price: 1.0, status: "created")
      create(:order, customer_id: 1, product_name: "B", quantity: 1, price: 2.0, status: "created")

      get "/orders", params: { customer_id: 1 }

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end

  describe "GET /orders without customer_id" do
    it "returns 400 bad request with JSON:API error" do
      get "/orders"
      expect(response).to have_http_status(:bad_request)
      expect(json_errors[0]["status"]).to eq("400")
    end
  end
end
