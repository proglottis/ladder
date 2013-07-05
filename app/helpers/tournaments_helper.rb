module TournamentsHelper
  def streak_badge(streak)
    return unless streak.eligible?

    colors = {true => 'success', false => 'important'}
    styles = ['pull-right', 'badge', "badge-#{colors[streak.winning?]}"]

    content_tag(:span, streak.lenght, :class => styles.join(' '))
  end
end
