class AddCommentColumnToRate < ActiveRecord::Migration
  def change
    add_column :rates, :comment, :text
  end
end
