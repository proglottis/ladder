class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_canditates, use: :slugged

  belongs_to :preferred_service, :class_name => 'Service'
  has_many :services
  has_many :players

  def self.anonymize
    find_each do |user|
      user.anonymize
    end
  end

  def anonymize
    update_attributes :name => "User #{id}", :email => "user_#{id}@example.com"
  end

  def slug_canditates
    [
      :name,
      [:name, :id],
    ]
  end
end
