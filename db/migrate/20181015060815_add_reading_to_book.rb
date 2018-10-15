class AddReadingToBook < ActiveRecord::Migration
  def change
    add_column :books, :reading, :boolean, default: true
  end
end
