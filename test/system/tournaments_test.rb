require "application_system_test_case"

class TournamentsTest < ApplicationSystemTestCase
  before do
    @service = login_service
  end

  describe "listing" do
    before do
      @tournaments = create_list(:started_tournament, 5, :owner => @service.user)
    end

    it "must show tournaments" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.title')
      @tournaments.each do |tournament|
        assert_link tournament.name
      end
      assert_link I18n.t('tournaments.index.start')
    end
  end

  describe "creation" do
    it "must be created" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.title')
      click_link I18n.t('tournaments.index.start')
      fill_in 'Name', :with => 'Test Tournament'
      select "Glicko2", from: "tournament_ranking_type"
      click_button I18n.t('helpers.submit.tournament.create')
      assert_text 'Test Tournament'
    end

    it "must fail with empty name" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.title')
      click_link I18n.t('tournaments.index.start')
      click_button I18n.t('helpers.submit.tournament.create')
      assert_text I18n.t('tournaments.new.title')
    end

    it "must be created" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.title')
      click_link I18n.t('tournaments.index.start')
      fill_in 'Name', :with => 'Test Tournament'
      select "King of the hill", from: "tournament_ranking_type"
      click_button I18n.t('helpers.submit.tournament.create')
      assert_text 'Test Tournament'
    end
  end

  describe "joining" do
    before do
      @tournament = create(:started_tournament, :owner => @service.user)
    end

    it "must let owner join" do
      visit tournament_path(@tournament)
      click_link I18n.t('layouts.tournament_title.join.link')
      refute_link I18n.t('layouts.tournaments_title.join.link')
    end
  end

  describe "updating" do
    before do
      @other_user = create(:user, :name => "Hao")
      @tournament = create(:started_tournament, :owner => @service.user)
      @rating_period = @tournament.current_rating_period
      @player1 = create(:player, :user => @service.user, :tournament => @tournament)
      @player2 = create(:player, :tournament => @tournament)
      create(:rating, :rating_period => @rating_period, :player => @player1)
      create(:rating, :rating_period => @rating_period, :player => @player2)
    end

    it "must let owner update" do
      visit tournament_path(@tournament)
      click_link I18n.t('tournaments.admin.title')
      fill_in 'Name', :with => 'New Name'
      click_button I18n.t('helpers.submit.update')
      assert_text 'New Name'
    end

    it "wont let others update" do
      @tournament.update_attributes! :owner => @other_user
      visit tournament_path(@tournament)
      refute_link I18n.t('tournaments.admin.title')
    end

    it "transfers ownership to others via update" do
      create(:player, :user => @other_user, :tournament => @tournament)

      visit tournament_path(@tournament)
      click_link I18n.t('tournaments.admin.title')
      select @other_user.name, from: "tournament_owner_id"
      click_button I18n.t('helpers.submit.update')
      assert_text 'Ownership of the tournament has been transferred. You are no longer the owner of the tournament.'
    end
  end
end
