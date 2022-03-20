# frozen_string_literal: true

class CustomerRepresenter < Representable::Decorator
  include Representable::JSON

  property :id
  property :first_name
  property :last_name
  property :email
end
