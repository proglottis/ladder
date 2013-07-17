require "test_helper"

describe Player do
  before do
    @player = Player.new
  end

  it "must be valid" do
    @player.valid?.must_equal true
  end
end
