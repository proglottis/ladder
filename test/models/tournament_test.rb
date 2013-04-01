require "test_helper"

describe Tournament do
  describe ".create" do
    it "will only allow owner to have a limited number" do
      @user = create(:user)
      @tournaments = create_list(:tournament, 5, :owner => @user)
      @tournament = @user.tournaments.create(attributes_for(:tournament))
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
      @rating_period = @tournament.current_rating_period
    end

    it "wont match users who are unrelated" do
      Tournament.participant(@user).wont_include @tournament
    end

    it "must match users who are owners" do
      @tournament.update_attribute(:owner, @user)
      Tournament.participant(@user).must_include @tournament
    end

    it "must match users who are rated" do
      create(:rating, :rating_period => @rating_period, :user => @user)
      Tournament.participant(@user).must_include @tournament
    end

    it "must match users who accepted an invite" do
      create(:invite, :tournament => @tournament, :user => @user)
      Tournament.participant(@user).must_include @tournament
    end
  end

  describe ".with_rated_user" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
      @tournament = create(:started_tournament)
      @rating_period = @tournament.current_rating_period
      @rating1 = create(:rating, :user => @user1, :rating_period => @rating_period)
      @rating2 = create(:rating, :user => @user2, :rating_period => @rating_period)
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

  describe "#has_user?" do
    before do
      @tournament = create(:started_tournament)
      @rating_period = @tournament.current_rating_period
      @users = create_list(:user, 2)
      @rating = create(:rating, :user => @users.first, :rating_period => @rating_period)
    end

    it "must match users who are participating" do
      @tournament.has_user?(@users.first).must_equal true
    end

    it "wont match users who are not participating" do
      @tournament.has_user?(@users.last).must_equal false
    end
  end
end
