class ChampionshipPlayer < ActiveRecord::Base
  belongs_to :championship
  belongs_to :player

  validates_presence_of :championship
  validates_presence_of :player
  validates_uniqueness_of :player_id, scope: :championship_id
  validate :championship_not_started, on: :create

  private

  def championship_not_started
    if championship && championship.started?
      errors.add(:championship, 'already started')
    end
  end
end
