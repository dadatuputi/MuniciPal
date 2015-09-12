class AddColumnsToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :zip_code, :string
    add_column :courts, :lat, :float
    add_column :courts, :long, :float
  end
end
