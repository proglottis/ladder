class AddCommentedEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :commented_email, :boolean, default: true, null: false
  end
end
