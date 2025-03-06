class UpdateContractorsTable < ActiveRecord::Migration[7.1]
  def change
    # Renaming existing columns
    rename_column :contractors, :name, :first_name
    rename_column :contractors, :address, :address_line

    # Adding new columns
    add_column :contractors, :last_name, :string
    add_column :contractors, :city, :string
    add_column :contractors, :country, :string
    add_column :contractors, :zip_code, :string
  end
end
