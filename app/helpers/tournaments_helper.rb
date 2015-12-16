module TournamentsHelper
  def streak_badge(player)
    return unless player.streak?

    colors = {true => 'success', false => 'danger'}
    styles = ['pull-right', 'label', "label-#{colors[player.winning_streak?]}"]

    content_tag(:span, player.winning_streak_count + player.losing_streak_count, :class => styles.join(' '))
  end

  def tournament_admin?
    case
    when
      ['tournaments'].include?(controller_name) && params['action'] == 'edit',
      ['games'].include?(controller_name) && params['action'] == 'index',
      ['players'].include?(controller_name) && params['action'] == 'index',
      ['invite_requests'].include?(controller_name) && params['action'] == 'index'
        true
    else
      false
    end
  end

  def link_to_admin(tournament)
    return if !user_logged_in? || tournament.owner_id != current_user.id

    styles = []
    styles << 'active' if tournament_admin?

    content_tag(:li, link_to(t('tournaments.admin.title'), edit_tournament_path(tournament)), :class => styles.join(' '))
  end
end
