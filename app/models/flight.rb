# frozen_string_literal: true

class Flight < ApplicationRecord
  belongs_to :customer

  validates :airline_code, presence: true
  validates :arrival_airport_code, presence: true
  validates :departure_airport_code, presence: true
  validates :departure_date, presence: true
  validates :flight_number, presence: true
end
