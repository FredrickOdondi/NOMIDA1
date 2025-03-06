class CreateReportConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :report_configurations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :report_type
      t.json :layout

      t.timestamps
    end
  end
end
