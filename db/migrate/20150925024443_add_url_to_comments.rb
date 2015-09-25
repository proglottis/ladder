class AddUrlToComments < ActiveRecord::Migration
  def up
    change_column :comments, :content, :text, :null => true
    add_column :comments, :url, :string
  end

  def down
    change_column :comments, :content, :text, :null => false
    remove_column :comments, :url, :string
  end
end
