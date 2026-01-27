# frozen_string_literal: true

# Request spec helpers to work with JSON/JSON:API responses.
module JsonHelpers
  # Parses the raw response body into a Ruby hash.
  def json_body
    JSON.parse(response.body)
  end

  # Returns the `data` member (JSON:API primary data).
  def json_data
    json_body["data"]
  end

  # Returns the `errors` array (JSON:API error objects).
  def json_errors
    json_body["errors"] || []
  end

  # Convenience accessor for attributes on primary data.
  # Works with both singular resources and collections (returns first item).
  def json_attr(key)
    data = json_data
    return nil unless data

    attrs = data.is_a?(Array) ? data.first["attributes"] : data["attributes"]
    attrs&.[](key.to_s)
  end
end

RSpec.configure do |config|
  config.include JsonHelpers, type: :request
end

