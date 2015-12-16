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
      @player1.end_at.wont_equal nil
      @player1.position.must_equal nil
    end

    it "shifts remaining players up" do
      PlayerRemover.new(@player1).remove
      @player2.reload.position.must_equal 1
      @player3.reload.position.must_equal 2
    end

    it "wont touch players with a smaller position" do
      PlayerRemover.new(@player2).remove
      @player1.reload.position.must_equal 1
      @player3.reload.position.must_equal 2
    end

    it "wont touch players when another player has the same position" do
      @player2_equal = create(:player, tournament: @tournament, position: 2)
      PlayerRemover.new(@player2).remove
      @player1.reload.position.must_equal 1
      @player2_equal.reload.position.must_equal 2
      @player3.reload.position.must_equal 3
    end
  end
end
