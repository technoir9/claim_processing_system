class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render status: :not_found, json: { error: 'Record not found' }
  end
end
