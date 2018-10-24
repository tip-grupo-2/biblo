class AddReadingDefaultToCopy < ActiveRecord::Migration
  def change
    change_column :copies, :reading, :boolean, default: false
  end
end
