class InviteRequest < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :user
  belongs_to :invite

  def self.not_completed
    where(completed_at: nil)
  end

  def completed?
    completed_at.present?
  end
end
