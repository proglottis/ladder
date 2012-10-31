class AddFirstNameAndLastNameAndImageUrlToService < ActiveRecord::Migration
  def change
    add_column :services, :first_name, :string
    add_column :services, :last_name, :string
    add_column :services, :image_url, :string
  end
end
