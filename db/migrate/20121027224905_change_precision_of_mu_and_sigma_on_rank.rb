class ChangePrecisionOfMuAndSigmaOnRank < ActiveRecord::Migration
  def up
    change_column :ranks, :mu, :decimal, :precision => 38, :scale => 10, :null => false
    change_column :ranks, :sigma, :decimal, :precision => 38, :scale => 10, :null => false
  end

  def down
    change_column :ranks, :mu, :decimal, :precision => 38, :scale => 5, :null => false
    change_column :ranks, :sigma, :decimal, :precision => 38, :scale => 5, :null => false
  end
end
