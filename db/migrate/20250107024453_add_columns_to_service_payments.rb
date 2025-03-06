class AddColumnsToServicePayments < ActiveRecord::Migration[7.1]
  def change
    add_column :service_payments, :paid_to_individuals_no_retention, :decimal
    add_column :service_payments, :paid_to_corporation_no_retention, :decimal
    add_column :service_payments, :paid_to_individuals_with_retention, :decimal
    add_column :service_payments, :retention_percentage_individuals, :decimal
    add_column :service_payments, :retention_individuals, :decimal
    add_column :service_payments, :paid_to_corporation_with_retention, :decimal
    add_column :service_payments, :retention_percentage_corporations, :decimal
    add_column :service_payments, :retention_corporations, :decimal
    add_column :service_payments, :reimbursed_expenses, :decimal
    add_column :service_payments, :responsibility_payment_health_providers, :decimal
    add_column :service_payments, :special_contribution_services, :decimal
    add_column :service_payments, :net_payment, :decimal
  end
end
