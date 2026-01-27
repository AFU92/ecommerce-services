class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render_jsonapi_error(status: :not_found, title: "Not Found", detail: "Record not found")
  end

  private

  def render_jsonapi_error(status:, title:, detail:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status).to_s
    render json: { errors: [{ status: code, title: title, detail: detail }] }, status: status
  end
end
