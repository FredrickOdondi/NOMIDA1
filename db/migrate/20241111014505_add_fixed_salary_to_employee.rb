class AddFixedSalaryToEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :fixed_salary, :decimal
  end
end
