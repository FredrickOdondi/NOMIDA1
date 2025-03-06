class AddFieldsRelatedToTimeToServicePayments < ActiveRecord::Migration[7.1]
  def change
    add_column :service_payments, :payment_method, :string
    add_column :service_payments, :period_start, :date
    add_column :service_payments, :period_end, :date
    remove_column :service_payments, :amount_a, :decimal
    remove_column :service_payments, :amount_b, :decimal
    remove_column :service_payments, :amount_c, :decimal
    remove_column :service_payments, :net_payment, :decimal
    remove_column :service_payments, :deduction_percentage, :decimal
  end
end
