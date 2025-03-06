class AddColumnMedicareToPayRolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :medicare, :decimal
  end
end
