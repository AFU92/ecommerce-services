# frozen_string_literal: true

# Exposes customer read endpoint returning JSON:API data.
# Renders 200 with serialized customer.
class CustomersController < ApplicationController
  # Renders a single customer as JSON:API.
  # Returns 200 or raises ActiveRecord::RecordNotFound.
  def show
    customer = Customer.find(params[:id])
    render json: CustomerSerializer.new(customer).serializable_hash
  end
end
