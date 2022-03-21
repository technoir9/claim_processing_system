# frozen_string_literal: true

module Claims
  class Create
    extend Dry::Initializer
    include Dry::Monads[:result]

    param :claim_params, Dry.Types::Hash, reader: :private

    def call
      claim = Claim.new(claim_params)

      return Failure('Claim must have at least one flight') if claim.flights.empty?

      if claim.save
        Success()
      else
        Failure(claim.errors.to_hash)
      end
    end
  end
end
