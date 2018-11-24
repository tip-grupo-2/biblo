class AddCreatedAtToRate < ActiveRecord::Migration
  def change
    add_column :rates, :created_at, :datetime, null: false
    add_column :rates, :updated_at, :datetime, null: false
  end
end
