class AddAcumsToPayRolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :current_acum_vacation_hours, :decimal
    add_column :payrolls, :current_acum_sickness_hours, :decimal
  end
end
