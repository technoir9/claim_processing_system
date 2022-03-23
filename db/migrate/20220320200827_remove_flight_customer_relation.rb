class RemoveFlightCustomerRelation < ActiveRecord::Migration[6.1]
  def change
    remove_reference :flights, :customer
  end
end
