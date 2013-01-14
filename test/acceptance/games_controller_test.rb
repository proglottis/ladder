require "minitest_helper"

describe "GamesController Acceptance Test" do

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
      click_link "Game"
      click_button "Create"
      must_have_content @rating1.user.name
      must_have_content @rating2.user.name
      must_have_content "Unconfirmed"
    end
  end

  describe "confirming" do
    before do
      @game = create(:game, :tournament => @tournament)
      @game_rank1 = @game.game_ranks.create(attributes_for(:game_rank, :user => @rating1.user, :position => 1))
      @game_rank2 = @game.game_ranks.create(attributes_for(:game_rank, :user => @rating2.user, :position => 2))
    end

    it "must be confirmed" do
      visit tournament_game_path @tournament, @game
      click_link "Confirm"
      must_have_content "Confirmed"
    end

    it "must update ranks and ratings on final confirmation" do
      @game_rank2.confirm
      visit tournament_game_path @tournament, @game
      click_link "Confirm"
      must_have_content @tournament.name
      @rating1.reload.rating.wont_be_close_to Glicko2::DEFAULT_GLICKO_RATING
      @rating2.reload.rating.wont_be_close_to Glicko2::DEFAULT_GLICKO_RATING
    end
  end

end
