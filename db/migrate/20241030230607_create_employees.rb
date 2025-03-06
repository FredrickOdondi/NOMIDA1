class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :social_security
      t.date :birth_date
      t.date :start_date
      t.string :phone_number
      t.decimal :hourly_rate
      t.string :address

      t.timestamps
    end
  end
end
