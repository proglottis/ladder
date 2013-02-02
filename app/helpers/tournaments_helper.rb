module TournamentsHelper
  def pending_confirmation_items_for(tournament, current_user)
    pending = tournament.game_ranks.not_confirmed.with_participant(current_user)
    content = ''
    if pending.present?
      content += content_tag(:li, 'Pending Confirmation', :class => 'nav-header')
      pending.each do |game_rank|
        content += content_tag(:li, link_to(game_rank.game.versus, tournament_game_path(game_rank.game.tournament, game_rank.game)))
      end
    end
    content.html_safe
  end
end
