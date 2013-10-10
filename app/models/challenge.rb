class Challenge < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :challenger, :class_name => 'User'
  belongs_to :defender, :class_name => 'User'
  belongs_to :game

  has_many :comments, -> { order('created_at DESC') }, :as => :commentable, :dependent => :destroy
end
