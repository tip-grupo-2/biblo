class AddOriginalOwnerToCopies < ActiveRecord::Migration
  def change
    add_column :copies, :original_owner_id, :integer
  end
end
