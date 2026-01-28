class ApplicationController < ActionController::API
  private

  def render_jsonapi_error(status:, title:, detail:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    render json: { errors: [{ status: code.to_s, title: title, detail: detail }] }, status: status
  end
end
