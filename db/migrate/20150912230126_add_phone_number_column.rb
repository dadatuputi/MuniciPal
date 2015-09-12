class AddPhoneNumberColumn < ActiveRecord::Migration
  def up
    add_column :people, :phone_number, :integer
    add_column :people, :sms_state, :integer
  end

  def down
    remove_column :people, :phone_number
    remove_column :people, :sms_state
  end
end
