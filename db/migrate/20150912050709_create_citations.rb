class CreateCitations < ActiveRecord::Migration
  def change
    create_table :citations do |t|
      t.string :citation_number
      t.date :citation_date
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :defendant_address
      t.string :defendant_city
      t.string :defendant_state
      t.string :drivers_license_number
      t.date :court_date
      t.string :court_location
      t.string :court_address
    end
  end
end
