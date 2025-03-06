class AddColumnToPayRolls < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :index_number, :integer
  end
end
