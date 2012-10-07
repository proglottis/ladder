class Tournament < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :ranks
  has_many :users, :through => :ranks

  attr_accessible :name

  validates_presence_of :name, :owner_id
end
