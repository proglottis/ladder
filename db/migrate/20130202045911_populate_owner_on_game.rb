class PopulateOwnerOnGame < ActiveRecord::Migration
  def up
    Game.find_each do |game|
      game.owner = game.game_ranks.first.user
      game.save
    end
  end

  def down
  end
end
