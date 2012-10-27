require 'rubygems'
require 'saulabs/trueskill'

include Saulabs::TrueSkill

# team 1 has just one player with a mean skill of 27.1, a skill-deviation of 2.13
# and an play activity of 100 %
team1 = [Rating.new(27.1, 2.13, 1.0)]

# team 2 has two players
team2 = [Rating.new(22.0, 0.98, 0.8), Rating.new(31.1, 5.33, 0.9)]

# team 1 finished first and team 2 second
graph = FactorGraph.new(team1 => 1, team2 => 2)

# update the Ratings
graph.update_skills
