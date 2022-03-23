class CreateClaims < ActiveRecord::Migration[6.1]
  def change
    create_table :claims do |t|
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
