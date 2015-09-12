class AddWebsiteColumnsToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :municipal_website, :string
    add_column :courts, :website, :string
    add_column :courts, :online_payment_provider, :string
  end
end
