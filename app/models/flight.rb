# frozen_string_literal: true

class Flight < ApplicationRecord
  belongs_to :claim

  validates :airline_code, presence: true
  validates :arrival_airport_code, presence: true
  validates :departure_airport_code, presence: true
  validates :departure_date, presence: true
  validates :flight_number, presence: true

  def identifier
    "#{airline_code}-#{flight_number}-#{departure_date.to_s.gsub('-', '')}-#{departure_airport_code}-#{arrival_airport_code}"
  end
end
