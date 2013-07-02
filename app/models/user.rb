class User < ActiveRecord::Base
  belongs_to :preferred_service, :class_name => 'Service'
  has_many :services
  has_many :tournaments, :inverse_of => :owner, :foreign_key => :owner_id
  has_many :invites, :inverse_of => :owner, :foreign_key => :owner_id

  def self.anonymize
    find_each do |user|
      user.anonymize
    end
  end

  def anonymize
    update_attributes :name => "User #{id}", :email => "user_#{id}@example.com"
  end
end
