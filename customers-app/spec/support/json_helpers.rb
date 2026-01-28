# frozen_string_literal: true

module JsonHelpers
  def json_body
    JSON.parse(response.body)
  end

  def json_data
    json_body["data"]
  end

  def json_errors
    json_body["errors"] || []
  end

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

