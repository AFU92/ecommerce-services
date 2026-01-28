class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    Rails.logger.warn(message: ::Constants::LOG_NOT_FOUND, path: request.path)
    render_jsonapi_error(status: :not_found, title: ::Constants::NOT_FOUND, detail: ::Constants::RECORD_NOT_FOUND_MSG)
  end

  private

  def render_jsonapi_error(status:, title:, detail:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    # Fallbacks for Rack 3 deprecations (e.g., :unprocessable_entity)
    code ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_content] if status == :unprocessable_entity
    code = code.to_i
    render json: { errors: [{ status: code.to_s, title: title, detail: detail }] }, status: status
  end
end
