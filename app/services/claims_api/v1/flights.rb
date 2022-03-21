# frozen_string_literal: true

module ClaimsApi
  module V1
    class Flights
      extend Dry::Initializer
      include Dry::Monads[:result]

      param :flight, Dry.Types::Instance(Flight), reader: :private

      def call
        api_client.get(query: { flight_identifier: flight.identifier})
      end

      private

      def api_client
        ApiClient.new
      end
    end
  end
end
