class PlayerRemover
  def initialize(player)
    @player = player
    @tournament = player.tournament
  end

  def remove
    @tournament.with_lock do
      @player.lock!

      return if @player.end_at

      if !@tournament.players.active.where.not(id: @player.id).find_by(position: @player.position)
        other_players = @tournament.players.active.
          where.not(position: nil).
          where('players.position > ?', @player.position)

        other_players.each do |other_player|
          other_player.update_attributes!(position: other_player.position - 1)
        end
      end
      @player.update_attributes!(position: nil, end_at: Time.zone.now)
    end
  end
end
