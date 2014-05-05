require File.expand_path("../test_helper", File.dirname(__FILE__))

class TournamentsIntegrationTest < ActionDispatch::IntegrationTest
  before do
    @service = login_service
  end

  describe "listing" do
    before do
      @tournaments = create_list(:started_tournament, 5, :owner => @service.user)
    end

    it "must show tournaments" do
      visit tournaments_path
      @tournaments.each do |tournament|
        must_have_link tournament.name
      end
      must_have_link I18n.t('tournaments.index.start')
    end
  end

  describe "creation" do
    it "must be created" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.start')
      fill_in 'Name', :with => 'Test Tournament'
      click_button I18n.t('helpers.submit.tournament.create')
      must_have_content 'Test Tournament'
    end

    it "must fail with empty name" do
      visit tournaments_path
      click_link I18n.t('tournaments.index.start')
      click_button I18n.t('helpers.submit.tournament.create')
      must_have_content I18n.t('tournaments.new.title')
    end
  end

  describe "joining" do
    before do
      @tournament = create(:started_tournament, :owner => @service.user)
    end

    it "must let owner join" do
      visit tournament_path(@tournament)
      click_link I18n.t('layouts.tournament_title.join.link')
      wont_have_link I18n.t('layouts.tournaments_title.join.link')
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
      must_have_content 'New Name'
    end

    it "wont let others update" do
      @tournament.update_attributes :owner => @other_user
      visit tournament_path(@tournament)
      wont_have_link I18n.t('tournaments.admin.title')
    end

    it "transfers ownership to others via update" do
      create(:player, :user => @other_user, :tournament => @tournament)

      visit tournament_path(@tournament)
      click_link I18n.t('tournaments.admin.title')
      select @other_user.name, from: "tournament_owner_id"
      click_button I18n.t('helpers.submit.update')
      must_have_content 'Ownership of the tournament has been transferred. You are no longer the owner of the tournament.'
    end
  end
end
