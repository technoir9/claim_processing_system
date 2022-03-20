# frozen_string_literal: true

class Claim < ApplicationRecord
  belongs_to :customer
  has_many :flights, dependent: :nullify

  accepts_nested_attributes_for :customer, :flights
end
