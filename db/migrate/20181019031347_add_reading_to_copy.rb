class AddReadingToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :reading, :boolean
  end
end
