class Tournament < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'

  attr_accessible :name

  validates_presence_of :name, :owner_id
end
