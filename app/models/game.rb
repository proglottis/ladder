class Game < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :owner, :class_name => 'User'
  has_many :game_ranks, -> { order('position') }, :dependent => :destroy
  has_many :comments, -> { order('created_at DESC') }, :as => :commentable, :dependent => :destroy
  has_one :challenge

  accepts_nested_attributes_for :game_ranks

  attr_accessor :comment

  def self.with_participant(*users)
    games = arel_table
    n = 0
    user_joins = users.reduce(games) do |user_joins, user|
      n += 1
      game_ranks = GameRank.arel_table.alias("users_with_participant_#{n}")
      user_joins.join(game_ranks).on(games[:id].eq(game_ranks[:game_id]).
                                      and(game_ranks[:user_id].eq(user.id)))
    end
    joins(user_joins.join_sql)
  end

  def self.unconfirmed
    where(:confirmed_at => nil)
  end

  def confirm_user(user)
    with_lock do
      total = 0
      confirmed = 0
      game_ranks.each do |game_rank|
        game_rank.confirm if game_rank.user == user
        confirmed += 1 if game_rank.confirmed?
        total += 1
      end
      if total == confirmed
        update_attributes!(:confirmed_at => Time.zone.now) if confirmed_at.blank?
        true
      else
        false
      end
    end
  end

  def confirmed?
    confirmed_at != nil
  end

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.to_sentence(:two_words_connector => I18n.t('support.array.versus.two_words_connector'))
  end
end
