class RemoveAddressNotNullFromUsers < ActiveRecord::Migration
  def change
    change_column :users, :address, :string, :null => true
  end
end
