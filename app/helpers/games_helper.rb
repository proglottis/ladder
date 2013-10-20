module GamesHelper

  def pending_confirmation_badge
    count = GameRank.not_confirmed.with_participant(current_user).joins(:game).merge(Game.unconfirmed).count
    badge(count) if count > 0
  end

end
