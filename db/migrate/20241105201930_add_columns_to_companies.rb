class AddColumnsToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :employer, :string
    add_column :companies, :payer, :string
    add_column :companies, :jurisdiction, :string
  end
end
