class AddGeometryToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :geometry, :text
  end
end
