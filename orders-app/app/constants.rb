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

  # Service/client messages
  CUST_SVC_RETURNED = "Customers Service returned".freeze

  # Logger message keys
  LOG_CUST_NOT_FOUND = "cust_not_found".freeze
  LOG_CUST_SVC_BAD_STATUS = "cust_svc_bad_status".freeze
  LOG_CUST_SVC_UNAVAILABLE = "cust_svc_unavailable".freeze

  LOG_PUB_START = "pub_start".freeze
  LOG_PUB_OK = "pub_ok".freeze
  LOG_PUB_ERR = "pub_err".freeze

  LOG_REJECT_CUST = "reject_cust".freeze
  LOG_CUST_SVC_DOWN = "cust_svc_down".freeze
  LOG_PUB_FAIL = "pub_fail".freeze
  LOG_INVALID = "invalid".freeze

  LOG_MISSING_CUST_ID = "missing_customer_id".freeze
end
