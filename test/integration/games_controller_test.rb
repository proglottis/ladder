require "minitest_helper"

describe "GamesController Integration Test" do

  before do
    @service = login_service
    @tournament = create(:tournament)
    @user2 = create(:user)
    @rating1 = create(:rating, :tournament => @tournament, :user => @service.user)
    @rating2 = create(:rating, :tournament => @tournament, :user => @user2)
  end

  describe "creation" do
    it "must be created" do
      visit tournament_path @tournament
      click_link "Log a game"
      click_button "Create"
      must_have_content @rating1.user.name
      must_have_content @rating2.user.name
      must_have_content "Unconfirmed"
    end

    it "must send confirmation email" do
      visit tournament_path @tournament
      click_link "Log a game"
      click_button "Create"
      ActionMailer::Base.deliveries.length.must_equal 1
      email = ActionMailer::Base.deliveries.first
      email.to.must_equal [@user2.email]
    end
  end

  describe "confirming" do
    before do
      @game = create(:game, :tournament => @tournament)
      @game_rank1 = create(:game_rank, :game => @game, :user => @rating1.user, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :user => @rating2.user, :position => 2)
    end

    it "must be confirmed" do
      visit game_path @game
      click_link "Confirm"
      must_have_content "Confirmed"
    end

    it "must update game on final confirmation" do
      @game_rank2.confirm
      visit game_path @game
      click_link "Confirm"
      must_have_content @tournament.name
      @game.reload.confirmed?.must_equal true
    end
  end

end
