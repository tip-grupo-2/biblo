class AddCopyIdToBook < ActiveRecord::Migration
  def change
    add_column :books, :copy_id, 'INT'
  end
end
