class InviteRequest < ApplicationRecord
  belongs_to :tournament
  belongs_to :user
  belongs_to :invite, optional: true

  def self.not_completed
    where(completed_at: nil)
  end

  def completed?
    completed_at.present?
  end
end
