class ChangePersonPhoneNumberToString < ActiveRecord::Migration
  def change
    remove_column :people, :phone_number
    add_column :people, :phone_number, :string
  end
end
