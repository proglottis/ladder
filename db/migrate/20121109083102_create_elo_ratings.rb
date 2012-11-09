class CreateEloRatings < ActiveRecord::Migration
  def up
    create_table :elo_ratings do |t|
      t.references :user, :null => false
      t.references :tournament, :null => false
      t.integer :rating, :null => false
      t.integer :games_played, :null => false
      t.boolean :pro, :null => false

      t.timestamps
    end
    add_index :elo_ratings, :user_id

    Tournament.all.each do |tournament|
      tournament.users.each do |user|
        tournament.elo_ratings.with_defaults.create(:user => user)
      end

      tournament.games.order(:created_at).each do |game|
        game.process_elo
      end
    end
  end

  def down
    drop_table :elo_ratings
  end
end
