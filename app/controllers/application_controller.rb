# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, ClaimsApi::V1::ApiClient::NotFoundError do
    render status: :not_found, json: { error: 'Record not found' }
  end

  rescue_from ClaimsApi::V1::ApiClient::ClientError do |e|
    render status: e.status, json: { error: e.message }
  end

  rescue_from ClaimsApi::V1::ApiClient::ServerError do
    render status: :internal_server_error, json: { error: 'Internal server error' }
  end
end
