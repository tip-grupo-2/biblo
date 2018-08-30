class AddBookIdToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :book_id, 'INT'
  end
end
