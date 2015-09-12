class CreatePeople < ActiveRecord::Migration
  def up
    remove_column :citations, :first_name
    remove_column :citations, :last_name
    remove_column :citations, :date_of_birth
    remove_column :citations, :defendant_address
    remove_column :citations, :defendant_city
    remove_column :citations, :defendant_state
    remove_column :citations, :drivers_license_number

    add_column :citations, :person_id, :integer

    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :address
      t.string :city
      t.string :state
      t.string :drivers_license_number
    end
  end

  def down
    drop_table :people

    remove_column :citations, :person_id

    add_column :citations, :first_name, :string
    add_column :citations, :last_name, :string
    add_column :citations, :date_of_birth, :date
    add_column :citations, :defendant_address, :string
    add_column :citations, :defendant_city, :string
    add_column :citations, :defendant_state, :string
    add_column :citations, :drivers_license_number, :string
  end
end
