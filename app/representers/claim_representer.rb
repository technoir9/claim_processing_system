# frozen_string_literal: true

class ClaimRepresenter < Representable::Decorator
  include Representable::JSON

  property :id
  property :customer, decorator: CustomerRepresenter
  collection :flights, decorator: FlightRepresenter
end
