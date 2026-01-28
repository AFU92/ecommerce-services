class ApplicationController < ActionController::API
  private

  def render_jsonapi_error(status:, title:, detail:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    # Fallbacks for Rack 3 deprecations (e.g., :unprocessable_entity)
    code ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_content] if status == :unprocessable_entity
    code = code.to_i
    render json: { errors: [{ status: code.to_s, title: title, detail: detail }] }, status: status
  end
end
