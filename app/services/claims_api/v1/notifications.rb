# frozen_string_literal: true

module ClaimsApi
  module V1
    class Notifications
      extend Dry::Initializer

      GITHUB_USERNAME = ENV.fetch('GITHUB_USERNAME')

      param :claim, Dry.Types::Instance(Claim), reader: :private

      def call
        api_client.post(path: '/claim_notifications', params: params)
      end

      private

      def api_client
        ApiClient.new
      end

      def params
        {
          'claim_id' => claim.id,
          'requester' => GITHUB_USERNAME
        }
      end
    end
  end
end
