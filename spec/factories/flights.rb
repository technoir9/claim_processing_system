FactoryBot.define do
  factory :flight do
    customer
    departure_airport_code { 'WAW' }
    arrival_airport_code { 'KRK' }
    airline_code { 'FR' }
    flight_number { '123456' }
    departure_date { '2022-03-19' }
  end
end
