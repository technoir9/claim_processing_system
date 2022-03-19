class AddFlightReferenceToClaim < ActiveRecord::Migration[6.1]
  def change
    add_reference :flights, :claim, foreign_key: true
  end
end
