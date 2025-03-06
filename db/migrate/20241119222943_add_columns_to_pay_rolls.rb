class AddColumnsToPayRolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :hourly_rate, :decimal
    add_column :payrolls, :total_salaries, :decimal
    add_column :payrolls, :medical_plan, :decimal
    add_column :payrolls, :asume, :decimal
    add_column :payrolls, :donations, :decimal
    add_column :payrolls, :other_deductions_3, :decimal
    remove_column :payrolls, :wages
  end
end
