set :output, "#{path}/log/cron.log"

every :monday, at: "00:01" do
  runner "RatingPeriodProcessor.perform"
end
