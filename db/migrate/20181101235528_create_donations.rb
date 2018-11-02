class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :requester_id
      t.integer :giver_id
      t.integer :copy_id
      t.string :state
      t.string :address
    end
  end
end
