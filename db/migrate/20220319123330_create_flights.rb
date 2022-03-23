class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :departure_airport_code
      t.string :arrival_airport_code
      t.string :airline_code
      t.string :flight_number
      t.date :departure_date
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
