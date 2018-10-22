class AddRequestedToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :requested, :boolean, :default => false
  end
end
