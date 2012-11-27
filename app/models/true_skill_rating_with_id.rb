class TrueSkillRatingWithId < Saulabs::TrueSkill::Rating
  attr_accessor :id

  def initialize(mu, sigma, activity, id)
    super(mu, sigma, activity)
    @id = id
  end
end
