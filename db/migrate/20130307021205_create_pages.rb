class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.text :content
      t.integer :parent_id
      t.string :parent_type

      t.timestamps
    end

    add_index :pages, :parent_id
    add_index :pages, :parent_type
  end
end
