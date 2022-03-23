# frozen_string_literal: true

module Claims
  class Eligibility
    extend Dry::Initializer

    CANCELLED_STATUS = 'cancelled'
    DELAYED_STATUS = 'delayed'
    ON_TIME_STATUS = 'on_time'
    NO_DATA_STATUS = 'no_data'
    DELAY_THRESHOLD_IN_MINUTES = 180

    param :claim, Dry.Types::Instance(Claim), reader: :private

    def call
      eligible?
    end

    private

    def eligible?
      eligible = false

      claim.flights.each do |flight|
        api_response = ClaimsApi::V1::Flights.new(flight).call

        if flight_eligible?(api_response)
          eligible = true
          break
        end
      end

      eligible
    end

    def flight_eligible?(api_response)
      flight_status = api_response.first.fetch('flight_status')

      case flight_status
      when CANCELLED_STATUS
        true
      when DELAYED_STATUS
        delayed_enough?(api_response)
      when ON_TIME_STATUS
        false
      when NO_DATA_STATUS
        false
      end
    end

    def delayed_enough?(api_response)
      delay_minutes = api_response.first.fetch('delay_mins')
      delay_minutes > DELAY_THRESHOLD_IN_MINUTES
    end
  end
end
