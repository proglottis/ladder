class Invite < ActiveRecord::Base
  validates_presence_of :code, :email
  attr_accessible :email
end
