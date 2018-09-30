class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :requester_id
      t.integer :copy_id
      t.datetime :read_at
      t.string :action

      t.timestamps null: false
    end
  end
end
