require "test_helper"

class ChallengesIntegrationTest < ActionDispatch::IntegrationTest
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
      must_have_content @rating1.user.name
      must_have_content @rating2.user.name
    end

    it "must send challenge email" do
      perform_enqueued_jobs do
        visit tournament_path @tournament
        all('a', :text => I18n.t('tournaments.show.challenge')).last.click
        click_button I18n.t('helpers.submit.create')
        ActionMailer::Base.deliveries.length.must_equal 1
        email = ActionMailer::Base.deliveries.first
        email.to.must_equal [@user2.email]
      end
    end
  end
end
