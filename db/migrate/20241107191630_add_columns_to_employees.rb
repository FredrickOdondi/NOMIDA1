class AddColumnsToEmployees < ActiveRecord::Migration[7.1]
  def change
    remove_column :employees, :accumulated_vacation_hours
    remove_column :employees, :vacation_hours_as_of_date
    remove_column :employees, :accumulated_sick_hours
    remove_column :employees, :sick_hours_as_of_date
    remove_column :employees, :middle_initial
    add_column :employees, :last_name_2, :string # apellido materno
    add_column :employees, :middle_name, :string
    add_column :employees, :genre, :string
    add_column :employees, :employ, :string
    add_column :employees, :mobile_phone, :string
    add_column :employees, :status, :string
    add_column :employees, :email, :string
  end
end
