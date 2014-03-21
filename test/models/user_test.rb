require "test_helper"

describe Game do
  describe "#can_challenge?" do
    before do
      @tournament = create(:tournament)
      @player1 = create(:player, :tournament => @tournament)
      @player2 = create(:player, :tournament => @tournament)
      @user1 = @player1.user
      @user2 = @player2.user
    end

    describe "with challenge" do
      before do
        @game = create(:challenge_game, :owner => @user1, :tournament => @tournament)
        @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
        @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
      end

      it "must be false when challenging" do
        @user1.can_challenge?(@player2).must_equal false
      end

      it "must be false when defending" do
        @user2.can_challenge?(@player1).must_equal false
      end
    end

    describe "without challenge" do
      it "must be true when there is no active challenge" do
        @user1.can_challenge?(@player2).must_equal true
        @user2.can_challenge?(@player1).must_equal true
      end

      it "must be true when there are unrelated challenges" do
        create(:challenge_game, :tournament => @tournament)
        @user1.can_challenge?(@player2).must_equal true
        @user2.can_challenge?(@player1).must_equal true
      end

      it "must be true when there are unrelated games" do
        create(:unconfirmed_game, :tournament => @tournament)
        @user1.can_challenge?(@player2).must_equal true
        @user2.can_challenge?(@player1).must_equal true
      end
    end
  end
end
