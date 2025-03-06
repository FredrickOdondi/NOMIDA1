class CreateServicePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :service_payments do |t|
      t.references :contractor, null: false, foreign_key: true
      t.date :payment_date
      t.decimal :amount_a
      t.decimal :amount_b
      t.decimal :amount_c
      t.decimal :deduction_percentage
      t.decimal :gross_amount
      t.decimal :deduction_amount
      t.decimal :net_amount

      t.timestamps
    end
  end
end
