require 'securerandom'

class Invite < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  validates_presence_of :tournament_id, :code, :email
  attr_accessible :email

  before_validation :generate_code
  before_validation :generate_expires_at
  after_create :send_invite

  def self.available
    invites = arel_table
    where(invites[:expires_at].gt(Time.now).and(invites[:user_id].eq(nil)))
  end

  def to_param
    code
  end

  def send_invite
    InviteMailer.invite_email(self).deliver
  end

  private

  def generate_code
    self.code = SecureRandom.urlsafe_base64 if code.blank?
  end

  def generate_expires_at
    self.expires_at = 7.days.from_now
  end
end
