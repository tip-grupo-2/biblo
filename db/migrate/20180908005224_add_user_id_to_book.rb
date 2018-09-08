class AddUserIdToBook < ActiveRecord::Migration
  def change
    add_column :books, :user_id, 'INT'
  end
end
