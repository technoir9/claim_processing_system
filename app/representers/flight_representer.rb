# frozen_string_literal: true

class FlightRepresenter < Representable::Decorator
  include Representable::JSON

  property :id
  property :airline_code
  property :arrival_airport_code
  property :departure_airport_code
  property :departure_date
  property :flight_number
end
