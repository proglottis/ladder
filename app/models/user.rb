class User < ActiveRecord::Base
  has_many :services
  has_many :tournaments, :inverse_of => :owner, :foreign_key => :owner_id
  has_many :invites, :inverse_of => :owner, :foreign_key => :owner_id
end
