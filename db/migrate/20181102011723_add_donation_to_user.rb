class AddDonationToUser < ActiveRecord::Migration
  def change
    add_column :users, :donation_id, :integer
  end
end
