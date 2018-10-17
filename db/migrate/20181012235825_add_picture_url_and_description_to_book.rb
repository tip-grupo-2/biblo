class AddPictureUrlAndDescriptionToBook < ActiveRecord::Migration
  def change
      add_column :books, :picture_url, :string
      add_column :books, :description, :string
  end
end
