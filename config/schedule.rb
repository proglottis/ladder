set :output, "#{path}/log/cron.log"

every :monday, at: "00:01" do
  runner "RatingPeriodProcessor.perform"
end

every :day, :at => "00:00" do
  runner "ChallengeProcessor.perform"
end
