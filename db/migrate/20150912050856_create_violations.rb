class CreateViolations < ActiveRecord::Migration
  def change
    create_table :violations do |t|
      t.string :citation_number
      t.string :violation_number
      t.string :violation_description
      t.boolean :warrant_status
      t.string :warrant_number
      t.string :status
      t.date :status_date
      t.decimal :fine_amount, :precision => 8, :scale => 2
      t.decimal :court_cost, :precision => 8, :scale => 2
    end
  end
end
