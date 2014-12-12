require "test_helper"

describe Player do
  before do
    @player = create(:player)
  end

  describe "#set_position" do
    describe "when the tournament has 'king of the hill' style ranking" do
      before do
        @user = create(:user)
        @tournament = @player.tournament
        @tournament.update_attributes!(:ranking_type => 'king_of_the_hill')
      end

      describe "the first player" do
        before do
          @player.destroy
        end

        it "should be number 1" do
          @tournament.players.create(:user => @user).position.must_equal 1
        end
      end

      describe "consecutive players" do
        before do
          @player.update_attributes!(:position => 7)
        end

        it "should be the next greatest number"  do
          @tournament.players.create(:user => @user).position.must_equal 8
        end
      end
    end

    describe "when the tournament has 'glicko2' style ranking" do
      before do
        @user = create(:user)
        @tournament = @player.tournament
      end

      it "should be blank" do
        @tournament.players.create(:user => @user).position.must_equal nil
      end
    end
  end

  describe ".active" do
    it "finds players with end date" do
      player = create(:player, :end_at => 1.week.from_now)
      Player.active.must_include player
    end

    it "finds players without end date" do
      player = create(:player, :end_at => nil)
      Player.active.must_include player
    end

    it "wont find players outside of range" do
      player = create(:player, :end_at => 1.day.ago)
      Player.active.wont_include player
    end

    it "finds players with exclusive end date" do
      end_date = Time.zone.now
      player = create(:player, :end_at => end_date)
      Player.active(end_date).wont_include player
    end
  end

  describe "#streak?" do
    it "must be true if winning count is 3 or more" do
      @player.winning_streak_count = 3
      @player.losing_streak_count = 0
      @player.streak?.must_equal true
    end

    it "must be true if losing count is 3 or more" do
      @player.winning_streak_count = 0
      @player.losing_streak_count = 3
      @player.streak?.must_equal true
    end

    it "wont be true if winning and loosing count is less than 3" do
      @player.winning_streak_count = 0
      @player.losing_streak_count = 0
      @player.streak?.must_equal false
    end
  end

  describe "#winning_streak?" do
    it "must be true if count is 3 or more" do
      @player.winning_streak_count = 3
      @player.winning_streak?.must_equal true
    end

    it "must be false if count is less than 3" do
      @player.winning_streak_count = 0
      @player.winning_streak?.must_equal false
    end

    it "must be false if losing count is more than 1" do
      @player.losing_streak_count = 3
      @player.winning_streak_count = 3
      @player.winning_streak?.must_equal false
    end
  end

  describe "#losing_streak?" do
    it "must be true if count is 3 or more" do
      @player.losing_streak_count = 3
      @player.losing_streak?.must_equal true
    end

    it "must be false if count is less than 3" do
      @player.losing_streak_count = 0
      @player.losing_streak?.must_equal false
    end

    it "must be false if winning count is more than 1" do
      @player.losing_streak_count = 3
      @player.winning_streak_count = 3
      @player.losing_streak?.must_equal false
    end
  end
end
