# frozen_string_literal: true

class CustomersController < ApplicationController
  def show
    customer = Customer.find(params[:id])
    render json: CustomerSerializer.new(customer).serializable_hash
  end
end

