class AddPhoneNumberToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :phone_number, :string
  end
end
