class AddColumnToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :employment_code, :string
  end
end
