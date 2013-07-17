require "test_helper"

describe Tournament do
  describe ".create" do
    it "will only allow owner to have a limited number" do
      @user = create(:user)
      @tournaments = create_list(:tournament, 5, :owner => @user)
      @tournament = Tournament.where(:owner_id => @user).create(:name => "Test")
      @tournament.errors.size.must_equal 1
    end
  end

  describe ".destroy" do
    before do
      @tournament = create(:tournament)
    end

    it "must destroy descendant rating periods" do
      create(:rating_period, :tournament => @tournament)
      @tournament.destroy
      RatingPeriod.where(:tournament_id => @tournament.id).count.must_equal 0
    end

    it "must destroy descendant invites" do
      create(:invite, :tournament => @tournament)
      @tournament.destroy
      Invite.where(:tournament_id => @tournament.id).count.must_equal 0
    end

    it "must destroy descendant games" do
      create(:game, :tournament => @tournament)
      @tournament.destroy
      Game.where(:tournament_id => @tournament.id).count.must_equal 0
    end

    it "must destroy descendant challenges" do
      create(:challenge, :tournament => @tournament)
      @tournament.destroy
      Challenge.where(:tournament_id => @tournament.id).count.must_equal 0
    end

    it "must destroy descendant pages" do
      create(:page, :parent => @tournament)
      @tournament.destroy
      Page.where(:parent_type => Tournament, :parent_id => @tournament.id).count.must_equal 0
    end
  end

  describe ".participant" do
    before do
      @user = create(:user)
      @tournament = create(:started_tournament)
    end

    it "wont match users who are unrelated" do
      Tournament.participant(@user).wont_include @tournament
    end

    it "must match users who are owners" do
      @tournament.update_attribute(:owner, @user)
      Tournament.participant(@user).must_include @tournament
    end

    it "must match users who are players" do
      create(:player, :tournament => @tournament, :user => @user)
      Tournament.participant(@user).must_include @tournament
    end

    it "must match users who accepted an invite" do
      create(:invite, :tournament => @tournament, :user => @user)
      Tournament.participant(@user).must_include @tournament
    end
  end

  describe ".with_rated_user" do
    before do
      @tournament = create(:started_tournament)
      @player1 = create(:player, :tournament => @tournament)
      @player2 = create(:player, :tournament => @tournament)
      @user1 = @player1.user
      @user2 = @player2.user
    end

    it "must match when rated" do
      Tournament.with_rated_user(@user1).must_include @tournament
      Tournament.with_rated_user(@user2).must_include @tournament
    end

    it "wont match when not rated" do
      @user = create(:user)
      Tournament.with_rated_user(@user).wont_include @tournament
    end

    it "must match when both are rated" do
      Tournament.with_rated_user(@user1, @user2).must_include @tournament
    end

    it "wont match when both are not rated" do
      @user = create(:user)
      Tournament.with_rated_user(@user1, @user).wont_include @tournament
    end
  end

  describe "ordered_positions_per_user" do
    before do
      @tournament = create(:started_tournament)
      @rating_period = @tournament.current_rating_period
      @player1 = create(:player, :tournament => @tournament)
      @player2 = create(:player, :tournament => @tournament)
      @user1 = @player1.user
      @user2 = @player2.user
      @rating1 = create(:rating, :rating_period => @rating_period, :player => @player1)
      @rating2 = create(:rating, :rating_period => @rating_period, :player => @player2)

      @game1 = create(:game, :tournament => @tournament)
      create(:game_rank, :game => @game1, :player => @player1, :position => 1)
      create(:game_rank, :game => @game1, :player => @player2, :position => 2)
      @game1.confirm_user(@user1)
      @game1.confirm_user(@user2)

      @game2 = create(:game, :tournament => @tournament)
      create(:game_rank, :game => @game2, :player => @player1, :position => 2)
      create(:game_rank, :game => @game2, :player => @player2, :position => 1)
      @game2.confirm_user(@user1)
      @game2.confirm_user(@user2)

      @positions = @tournament.ordered_positions_per_user
    end

    it "returns user_id => ordered positions hash" do
      @positions.must_equal ({@user1.id => [1,2], @user2.id => [2,1]})
    end
  end
end
