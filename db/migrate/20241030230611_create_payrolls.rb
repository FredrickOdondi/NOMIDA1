class CreatePayrolls < ActiveRecord::Migration[7.1]
  def change
    create_table :payrolls do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :pay_date
      t.decimal :regular_hours
      t.decimal :overtime_hours
      t.decimal :vacation_hours
      t.decimal :sick_hours
      t.decimal :gross_salary
      t.decimal :reimbursed_expenses
      t.decimal :tips
      t.decimal :commissions
      t.decimal :non_taxable_income
      t.decimal :social_security
      t.decimal :medicare
      t.decimal :disability
      t.decimal :driver_insurance
      t.decimal :income_tax
      t.decimal :other_deductions_1
      t.decimal :other_deductions_2
      t.decimal :total_deductions
      t.decimal :net_pay

      t.timestamps
    end
  end
end
