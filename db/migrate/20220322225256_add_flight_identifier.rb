class AddFlightIdentifier < ActiveRecord::Migration[6.1]
  def change
    add_column :flights, :flight_identifier, :string
  end
end
