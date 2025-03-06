class UpdateEmployeesTable < ActiveRecord::Migration[7.1]
  def change
    # Renaming existing columns
    rename_column :employees, :name, :first_name
    rename_column :employees, :address, :address_line

    # Adding new columns
    add_column :employees, :middle_initial, :string
    add_column :employees, :last_name, :string
    add_column :employees, :employee_number, :string
    add_column :employees, :license_number, :string
    add_column :employees, :termination_date, :date
    add_column :employees, :is_driver, :boolean, default: false
    add_column :employees, :city, :string
    add_column :employees, :country, :string
    add_column :employees, :zip_code, :string
    add_column :employees, :accumulated_vacation_hours, :decimal, default: 0.0
    add_column :employees, :vacation_hours_as_of_date, :date
    add_column :employees, :accumulated_sick_hours, :decimal, default: 0.0
    add_column :employees, :sick_hours_as_of_date, :date
  end
end
