class Game < ActiveRecord::Base
  belongs_to :tournament
  has_many :game_ranks, :order => 'position'

  accepts_nested_attributes_for :game_ranks
end
