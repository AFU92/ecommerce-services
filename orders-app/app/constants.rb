# frozen_string_literal: true

module Constants
  ORDERS_EXCHANGE = "orders.events".freeze
  ORDERS_CREATED_KEY = "orders.created".freeze

  BAD_REQUEST = "Bad Request".freeze
  UNPROCESSABLE = "Unprocessable Entity".freeze
  BAD_GATEWAY = "Bad Gateway".freeze
  INTERNAL_ERROR = "Internal Server Error".freeze
  NOT_FOUND = "Not Found".freeze

  CUSTOMER_ID_REQUIRED_MSG = "customer_id is required".freeze
  CUSTOMER_NOT_FOUND_MSG = "Customer not found".freeze
  RECORD_NOT_FOUND_MSG = "Record not found".freeze
end
