class AddDonationsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :donation_id, :integer
  end
end
