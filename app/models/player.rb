class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  has_many :ratings, :dependent => :destroy
  has_many :game_ranks, :dependent => :destroy
end
