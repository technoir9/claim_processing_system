class AddEligibilityToClaim < ActiveRecord::Migration[6.1]
  def change
    add_column :claims, :eligibility, :integer, null: false, default: 0
  end
end
