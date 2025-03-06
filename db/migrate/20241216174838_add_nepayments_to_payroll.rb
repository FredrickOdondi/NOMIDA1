class AddNepaymentsToPayroll < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :regular_hours_payment, :decimal
    add_column :payrolls, :overtime_hours_payment, :decimal
    add_column :payrolls, :vacation_hours_payment, :decimal
    add_column :payrolls, :sick_hours_payment, :decimal
  end
end
