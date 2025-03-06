class CreateContractors < ActiveRecord::Migration[7.1]
  def change
    create_table :contractors do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :contractor_type
      t.string :social_security_ein
      t.string :address
      t.string :phone_number

      t.timestamps
    end
  end
end
