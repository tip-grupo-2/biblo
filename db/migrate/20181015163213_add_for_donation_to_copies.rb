class AddForDonationToCopies < ActiveRecord::Migration
  def change
    add_column :copies, :for_donation, :boolean
  end
end
