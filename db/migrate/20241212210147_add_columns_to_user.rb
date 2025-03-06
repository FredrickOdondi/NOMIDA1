class AddColumnsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :last_name_2, :string
    add_column :users, :birth_date, :date
  end
end
