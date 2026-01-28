# Base API controller providing JSON:API error rendering.
# Shared across orders endpoints.
class ApplicationController < ActionController::API
  private

  # Renders a JSON:API error object with given status.
  # Includes status code, title, and detail.
  #
  # @param status [Symbol] HTTP status symbol.
  # @param title [String] Short error title.
  # @param detail [String] Human-readable error detail.
  # @return [void]
  def render_jsonapi_error(status:, title:, detail:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    # Fallbacks for Rack 3 deprecations (e.g., :unprocessable_entity)
    code ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_content] if status == :unprocessable_entity
    code = code.to_i
    render json: { errors: [ { status: code.to_s, title: title, detail: detail } ] }, status: status
  end
end
