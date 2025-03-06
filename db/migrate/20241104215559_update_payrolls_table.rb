class UpdatePayrollsTable < ActiveRecord::Migration[7.1]
  def change
    # Renaming existing columns
    rename_column :payrolls, :gross_salary, :gross_pay
    rename_column :payrolls, :reimbursed_expenses, :expense_reimbursement
    rename_column :payrolls, :non_taxable_income, :other_payments_not_subject_to_retention
    rename_column :payrolls, :social_security, :social_security_medicare

    # Adding new columns
    add_column :payrolls, :fixed_salary, :decimal
    add_column :payrolls, :wages, :decimal
    add_column :payrolls, :other_payments_subject_to_contribution, :decimal
    add_column :payrolls, :sinot, :decimal
    add_column :payrolls, :driver_weeks_worked, :decimal

    # Removing columns no longer needed
    remove_column :payrolls, :commissions, :decimal
    remove_column :payrolls, :medicare, :decimal
    remove_column :payrolls, :disability, :decimal
  end
end
