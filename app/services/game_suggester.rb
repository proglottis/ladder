class GameSuggester
  def initialize(rating, ratings)
    @rating = rating
    @ratings = ratings
    @rand = Random.new(Time.zone.now.beginning_of_day.to_i)
  end

  def suggest
    return if !@rating || @ratings.empty?

    closest = @ratings.select{|r| r.id != @rating.id }.sort_by {|r| (@rating.low_rank - r.low_rank).abs }
    closest.first(5).sample(random: @rand)
  end
end
