class UnconfirmedGameNotificationProcessor
  def initialize(reminder_date)
    @reminder_date = reminder_date
  end

  def self.perform
    processor = UnconfirmedGameNotificationProcessor.new(Time.zone.today)
    processor.process
  end

  def process
    GameRank.not_confirmed.where.not(created_at: @reminder_date.beginning_of_day..@reminder_date.end_of_day).group_by(&:user).each do |user, game_ranks|
      Notifications.unconfirmed_games(user, game_ranks).deliver_now if user.game_unconfirmed_email?
    end
  end
end
