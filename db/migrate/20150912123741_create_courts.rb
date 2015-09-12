class CreateCourts < ActiveRecord::Migration
  def up
    remove_column :citations, :court_location
    remove_column :citations, :court_address
    add_column :citations, :court_id, :integer

    create_table :courts do |t|
      t.string :name
      t.string :address
    end
  end

  def down
    drop_table :courts
    remove_column :citations, :court_id
    add_column :citations, :court_location, :string
    add_column :citations, :court_address, :string
  end
end
