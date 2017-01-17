class UnconfirmedGameNotificationJob < ApplicationJob
  queue_as :default

  def perform
    reminder_date = Time.zone.today

    GameRank.not_confirmed.where.not(created_at: reminder_date.beginning_of_day..reminder_date.end_of_day).group_by(&:user).each do |user, game_ranks|
      Notifications.unconfirmed_games(user, game_ranks).deliver_later if user.game_unconfirmed_email?
    end
  end
end
