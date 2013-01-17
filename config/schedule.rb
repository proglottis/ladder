set :output, "#{path}/log/cron.log"

every :sunday, at: "00:01" do
  runner "RatingPeriodProcessor.perform"
end
