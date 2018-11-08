class AddMaxDistanceToUser < ActiveRecord::Migration
  def change
    add_column :users, :max_distance, :integer, default: 5
  end
end
