class CreateBookRequest < ActiveRecord::Migration
  def change
    create_table :book_requests do |t|
      t.integer :recipient_id
      t.integer :requester_id
      t.integer :copy_id
      t.boolean :accepted
      t.belongs_to :notification, index: true
      t.timestamps null: false
    end
  end
end

