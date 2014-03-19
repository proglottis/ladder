require 'securerandom'

class Invite < ActiveRecord::Base
  OWNER_LIMIT = 10

  belongs_to :owner, :class_name => 'User'
  belongs_to :user
  belongs_to :tournament

  validates_presence_of :tournament_id, :code, :email
  validate :maximum_allowed_by_owner

  before_validation :generate_code
  before_validation :generate_expires_at

  def self.not_expired
    where("invites.expires_at > ?", Time.zone.now)
  end

  def self.available
    not_expired.where(:user_id => nil)
  end

  def self.limit_left
    OWNER_LIMIT - not_expired.count
  end

  def to_param
    code
  end

  private

  def generate_code
    self.code = SecureRandom.urlsafe_base64 if code.blank?
  end

  def generate_expires_at
    self.expires_at = 7.days.from_now
  end

  def maximum_allowed_by_owner
    if tournament.invites.where(:owner_id => owner).reload.limit_left < 1
      errors.add(:base, 'Exceeded limit')
    end
  end
end
