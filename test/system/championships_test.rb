require "application_system_test_case"

class ChampionshipsTest < ApplicationSystemTestCase
  before do
    @user1 = create(:user)
    @user2 = create(:user)
    @tournament = create(:started_tournament, owner: @user1)
    @rating_period = @tournament.current_rating_period
    @player1 = create(:player, :tournament => @tournament, :user => @user1)
    @player2 = create(:player, :tournament => @tournament, :user => @user2)
    @rating1 = create(:rating, :rating_period => @rating_period, :player => @player1)
    @rating2 = create(:rating, :rating_period => @rating_period, :player => @player2)
  end

  test "starting" do
    login_as(@user1)
    visit edit_tournament_path(@tournament)
    click_link I18n.t('tournaments.edit.championship.link')
    assert_text I18n.t('tournaments.championships.show.not_started')

    click_link I18n.t('tournaments.championships.show.join.link')
    refute_text I18n.t('tournaments.championships.show.join.link')

    login_as(@user2)
    visit tournament_championship_path(@tournament)
    click_link I18n.t('tournaments.championships.show.join.link')
    refute_text I18n.t('tournaments.championships.show.join.link')

    login_as(@user1)
    visit tournament_championship_path(@tournament)
    click_link I18n.t('tournaments.championships.show.start')
    refute_text I18n.t('tournaments.championships.show.start')
    assert_text I18n.t('tournaments.championships.show.bracket')
  end
end
