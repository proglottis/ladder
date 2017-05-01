require "test_helper"

describe PlayerRemover do
  before do
    @tournament = create(:started_tournament)
    @player1       = create(:player, tournament: @tournament, position: 1)
    @player2       = create(:player, tournament: @tournament, position: 2)
    @player3       = create(:player, tournament: @tournament, position: 3)
  end

  describe "#remove" do
    it "ends the player" do
      PlayerRemover.new(@player1).remove
      refute_nil @player1.end_at
      assert_nil @player1.position
    end

    it "shifts remaining players up" do
      PlayerRemover.new(@player1).remove
      assert_equal 1, @player2.reload.position
      assert_equal 2, @player3.reload.position
    end

    it "wont touch players with a smaller position" do
      PlayerRemover.new(@player2).remove
      assert_equal 1, @player1.reload.position
      assert_equal 2, @player3.reload.position
    end

    it "wont touch players when another player has the same position" do
      @player2_equal = create(:player, tournament: @tournament, position: 2)
      PlayerRemover.new(@player2).remove
      refute_nil @player2.reload.end_at
      assert_nil @player2.position
      assert_equal 1, @player1.reload.position
      assert_equal 2, @player2_equal.reload.position
      assert_equal 3, @player3.reload.position
    end
  end
end
