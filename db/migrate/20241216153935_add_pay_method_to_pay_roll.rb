class AddPayMethodToPayRoll < ActiveRecord::Migration[7.1]
  def change
    add_column :payrolls, :payment_method, :string
    add_column :payrolls, :period_start, :date
    add_column :payrolls, :period_end, :date
  end
end
