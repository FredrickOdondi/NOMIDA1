class AddEmailToContractors < ActiveRecord::Migration[7.1]
  def change
    add_column :contractors, :email, :string
  end
end
