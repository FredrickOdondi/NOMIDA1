class AddCommissionsBonusesExpenseReimbursementToPayrolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :commissions, :decimal
    add_column :payrolls, :bonuses, :decimal
    add_column :payrolls, :allowances, :decimal
    add_column :payrolls, :other_payments_subject_to_contribution_2, :decimal
  end
end
