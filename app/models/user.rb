class User < ActiveRecord::Base
  has_many :services
  has_many :tournaments, :inverse_of => :owner, :foreign_key => :owner_id

  attr_accessible :name, :email
end
