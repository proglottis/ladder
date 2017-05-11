require "application_system_test_case"

class ChallengesTest < ApplicationSystemTestCase
  before do
    @service = login_service
    @tournament = create(:started_tournament)
    @rating_period = @tournament.current_rating_period
    @player1 = create(:player, :user => @service.user, :tournament => @tournament)
    @player2 = create(:player, :tournament => @tournament)
    @user2 = @player2.user
    @rating1 = create(:rating, :rating_period => @rating_period, :player => @player1)
    @rating2 = create(:rating, :rating_period => @rating_period, :player => @player2)
  end

  describe "creation" do
    it "must be created" do
      visit tournament_path @tournament
      all('a', :text => I18n.t('tournaments.show.challenge')).last.click
      click_button I18n.t('helpers.submit.create')
      assert_text @rating1.user.name
      assert_text @rating2.user.name
    end

    it "must send challenge email" do
      visit tournament_path @tournament
      all('a', :text => I18n.t('tournaments.show.challenge')).last.click
      click_button I18n.t('helpers.submit.create')
      assert_equal 1, ActionMailer::Base.deliveries.length
      email = ActionMailer::Base.deliveries.first
      assert_equal [@user2.email], email.to
    end
  end

end
