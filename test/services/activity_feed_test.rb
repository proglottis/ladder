require "test_helper"

describe ActivityFeed do
  before do
    @user = create(:user)
    @tournament = create(:started_tournament)
    @player = create(:player, :user => @user, :tournament => @tournament)
    @game_with_user = create(:game, :tournament => @tournament)
    create(:game_rank, :game => @game_with_user, :player => @player)
    create(:game_rank, :game => @game_with_user)
    @game_without_user = create(:game, :tournament => @tournament)
    create(:game_rank, :game => @game_without_user)
    create(:game_rank, :game => @game_without_user)
    @challenge_with_user1 = create(:challenge, :tournament => @tournament, :challenger => @user)
    @challenge_with_user2 = create(:challenge, :tournament => @tournament, :defender => @user)
    @challenge_without_user = create(:challenge, :tournament => @tournament)
  end

  describe "#for_user" do
    describe "without viewing users" do
      it "must include games on a tournament a user participated in" do
        ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user).must_include(@game_with_user)
      end

      it "wont include games on a tournament a user did not participate in" do
        ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user).wont_include(@game_without_user)
      end

      it "must include challenges on a tournament a user participated in" do
        ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user).must_include(@challenge_with_user1)
        ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user).must_include(@challenge_with_user2)
      end

      it "wont include challenges on a tournament a user did not participate in" do
        ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user).wont_include(@challenge_without_user)
      end
    end

    describe "with viewing users" do
      before do
        @other_user = create(:user)
      end

      describe "in same tournament" do
        before do
          create(:player, :user => @other_user, :tournament => @tournament)
        end

        it "must include games on a tournament a user participated in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).must_include(@game_with_user)
        end

        it "wont include games on a tournament a user did not participate in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).wont_include(@game_without_user)
        end

        it "must include challenges on a tournament a user participated in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).must_include(@challenge_with_user1)
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).must_include(@challenge_with_user2)
        end

        it "wont include challenges on a tournament a user did not participate in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).wont_include(@challenge_without_user)
        end
      end

      describe "in different tournament" do
        it "wont include games on a tournament a user participated in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).wont_include(@game_with_user)
        end

        it "wont include challenges on a tournament a user participated in" do
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).wont_include(@challenge_with_user1)
          ActivityFeed.new(1.week.ago, Time.zone.now).for_user(@user, @other_user).wont_include(@challenge_with_user2)
        end
      end
    end
  end

  describe "#for_tournament" do
    before do
      @other_tournament = create(:tournament)
    end

    it "must include games on a tournament" do
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).must_include(@game_with_user)
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).must_include(@game_without_user)
    end

    it "must include challenges on a tournament" do
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).must_include(@challenge_with_user1)
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).must_include(@challenge_with_user2)
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).must_include(@challenge_without_user)
    end

    it "wont include games on a different tournament" do
      @other_game = create(:game, :tournament => @other_tournament)
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).wont_include(@other_game)
    end

    it "wont include games on a different tournament" do
      @other_challenge = create(:challenge, :tournament => @other_tournament)
      ActivityFeed.new(1.week.ago, Time.zone.now).for_tournament(@tournament).wont_include(@other_challenge)
    end
  end
end
