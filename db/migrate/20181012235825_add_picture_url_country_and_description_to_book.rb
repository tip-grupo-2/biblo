class AddPictureUrlCountryAndDescriptionToBook < ActiveRecord::Migration
  def change
      add_column :books, :picture_url, :string
      add_column :books, :description, :string
      add_column :books, :country, :string
  end
end
