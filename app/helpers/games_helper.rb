module GamesHelper

  def pending_confirmation_badge
    count = GameRank.not_confirmed.with_participant(current_user).count
    if count > 0
      content_tag :span, :class => 'badge badge-important' do
        "#{count}"
      end
    end
  end

end
