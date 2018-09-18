class AddUserIdToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :user_id, 'INT'
  end
end
