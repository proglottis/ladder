module TournamentsHelper
  def streak_badge(player)
    return unless player.streak?

    colors = {true => 'success', false => 'important'}
    styles = ['pull-right', 'badge', "badge-#{colors[player.winning_streak?]}"]

    content_tag(:span, player.winning_streak_count + player.losing_streak_count, :class => styles.join(' '))
  end
end
