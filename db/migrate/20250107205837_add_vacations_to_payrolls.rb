class AddVacationsToPayrolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :current_vacation_hours, :decimal
    add_column :payrolls, :current_sickness_hours, :decimal
  end
end
