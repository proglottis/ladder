class BackpopulateStreakCountOnPlayers < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      ordered_positions_per_player = tournament.game_ranks.includes(:player).
        where('games.confirmed_at IS NOT NULL').
        reorder('games.confirmed_at ASC').
        inject({}) {|h, r| h.update(r.player => (h[r.player] || []) << r.position)}

      ordered_positions_per_player.each do |player, positions|
        last = positions.last
        row = positions.reverse.take_while {|i| i == last}
        length = row.size
        if row.first == 1
          player.update_attributes! :winning_streak_count => length, :losing_streak_count => 0
        else
          player.update_attributes! :winning_streak_count => 0, :losing_streak_count => length
        end
      end
    end
  end

  def down
    Player.update_all winning_streak_count: 0, losing_streak_count: 0
  end
end
