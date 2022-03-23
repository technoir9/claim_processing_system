# frozen_string_literal: true

module Claims
  class Download
    extend Dry::Initializer

    HEADERS = %w[claim_id email first_name last_name flight_identifiers].freeze

    param :flight_identifier, Dry.Types::String, reader: :private

    def call
      Csv::Generate.new(HEADERS, rows).call
    end

    private

    def rows
      eligible_claims.map do |claim|
        [
          claim.id,
          claim.customer.email,
          claim.customer.first_name,
          claim.customer.last_name,
          claim.flights.pluck(:flight_identifier)
        ]
      end
    end

    def eligible_claims
      claims.select { |claim| Claims::Eligibility.new(claim).call }
    end

    def claims
      claim_ids = Flight.where(flight_identifier: flight_identifier).pluck(:claim_id)
      Claim.includes(:flights).where(id: claim_ids)
    end
  end
end
