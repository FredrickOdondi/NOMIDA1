class CreateParameters < ActiveRecord::Migration[7.1]
  def change
    create_table :parameters do |t|
      t.references :company, null: false, foreign_key: true
      t.string :parameter_name
      t.decimal :parameter_value

      t.timestamps
    end
  end
end
