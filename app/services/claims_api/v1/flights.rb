# frozen_string_literal: true

module ClaimsApi
  module V1
    class Flights
      extend Dry::Initializer

      param :flight, Dry.Types::Instance(Flight), reader: :private

      def call
        api_client.get(path: '/flights', query: { flight_identifier: flight.flight_identifier})
      end

      private

      def api_client
        ApiClient.new
      end
    end
  end
end
