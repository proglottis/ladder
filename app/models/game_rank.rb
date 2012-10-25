class GameRank < ActiveRecord::Base
  belongs_to :rank
  has_one :user, :through => :rank
  belongs_to :game

  acts_as_list :scope => :game
end
