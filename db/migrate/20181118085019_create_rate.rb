class CreateRate < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.integer :amount,    null: false
      t.integer :owner_id,  null: false
      t.belongs_to :user,   null: true
      t.belongs_to :copy,   null: true
      t.belongs_to :book,   null: true
    end
  end
end
