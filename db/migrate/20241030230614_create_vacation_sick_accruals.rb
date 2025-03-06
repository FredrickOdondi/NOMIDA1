class CreateVacationSickAccruals < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_sick_accruals do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :accrual_date
      t.decimal :vacation_hours
      t.decimal :sick_hours

      t.timestamps
    end
  end
end
