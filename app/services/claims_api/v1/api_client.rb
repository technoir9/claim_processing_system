# frozen_string_literal: true

module ClaimsApi
  module V1
    class ApiClient
      ApiError = Class.new(StandardError) do
        extend Dry::Initializer

        param :status, Dry.Types::Coercible::Integer, reader: :public
        param :message, Dry.Types::String, reader: :public, default: -> { '' }
      end
      ClientError = Class.new(ApiError)
      NotFoundError = Class.new(ApiError)
      ServerError = Class.new(ApiError)

      BASE_URL = ENV.fetch('CLAIM_API_URL')

      def get(path: '', query: {})
        response = Excon.get("#{BASE_URL}#{path}", query: query)
        handle_response(response)
      end

      def post(path: '', params: {})
        response = Excon.post(
          "#{BASE_URL}#{path}",
          body: params.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        handle_response(response)
      end

      private

      def handle_response(response)
        if response.status.in?(200..299)
          JSON.parse(response.body)
        elsif response.status == 404
          raise NotFoundError.new(response.status)
        elsif response.status.in?(400..499)
          raise ClientError.new(response.status, response.body)
        else
          raise ServerError.new(response.status, response.body)
        end
      end
    end
  end
end
