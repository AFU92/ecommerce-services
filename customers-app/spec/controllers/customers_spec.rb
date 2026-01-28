# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Customers", type: :request do
  describe "GET /customers/:id" do
    it "returns customer info (JSON:API)" do
      customer = create(:customer, customer_name: "Ana", address: "Street 1", orders_count: 2)

      get "/customers/#{customer.id}"

      expect(response).to have_http_status(:ok)
      expect(json_data["type"]).to eq("customer")
      expect(json_data["id"]).to eq(customer.id.to_s)
      expect(json_attr(:customer_name)).to eq("Ana")
      expect(json_attr(:orders_count)).to eq(2)
    end

    it "returns 404 when missing" do
      get "/customers/999999"
      expect(response).to have_http_status(:not_found)
      expect(json_errors[0]["status"]).to eq("404")
    end
  end
end
