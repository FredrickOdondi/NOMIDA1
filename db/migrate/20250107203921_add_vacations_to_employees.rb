class AddVacationsToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :initial_acum_vacation_hours, :decimal
    add_column :employees, :initial_acum_sickness_hours, :decimal
    add_column :employees, :current_acum_vacation_hours, :decimal
    add_column :employees, :current_acum_sickness_hours, :decimal
  end
end
