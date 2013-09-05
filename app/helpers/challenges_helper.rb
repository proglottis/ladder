module ChallengesHelper

  def defending_count_badge
    count = Challenge.active.defending(current_user).count
    if count > 0
      content_tag :span, :class => 'badge' do
        "#{count}"
      end
    end
  end

end
