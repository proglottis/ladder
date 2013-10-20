module ChallengesHelper

  def defending_count_badge
    count = Challenge.active.defending(current_user).count
    badge(count) if count > 0
  end

end
