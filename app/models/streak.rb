class Streak
  def initialize(input)
    @positions = input || []
  end

  def eligible?
    return false if @positions.size < min
    last_positions.uniq.size == 1
  end

  def winning?(min = 3)
    eligible? && last_positions.uniq.first == 1
  end

  def length
    last = positions.last
    row = positions.reverse.take_while {|i| i == last}
    row.size
  end

  private

  def min
    3
  end

  def positions
    @positions
  end

  def last_positions
    @last_positions ||= positions.last(min)
  end
end
