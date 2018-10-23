class AddInDonationToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :in_donation, :boolean, default: true
  end
end
