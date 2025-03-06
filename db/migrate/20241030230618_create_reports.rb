class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :company, null: false, foreign_key: true
      t.string :report_type
      t.timestamp :generated_date
      t.json :filters
      t.string :file_path

      t.timestamps
    end
  end
end
