class RemoveColumnsFromCompanies < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :employer_social_security, :string
    remove_column :companies, :address, :string
    remove_column :companies, :phone_number, :string
    remove_column :companies, :entity_name, :string
    add_column :companies, :website, :string
  end
end
