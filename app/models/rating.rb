class Rating < ActiveRecord::Base
  belongs_to :rating_period
  belongs_to :user

  validates_presence_of :rating_period_id, :user_id
end
