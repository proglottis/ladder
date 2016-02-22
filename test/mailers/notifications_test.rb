require "test_helper"

describe Notifications do
  describe "#tournament_invitation" do
    it "must contain tournament details" do
      @tournament = create(:tournament)
      @invite = create(:invite, :tournament => @tournament)
      mail = Notifications.tournament_invitation @invite
      mail.subject.must_equal I18n.t('notifications.tournament_invitation.subject')
      mail.to.must_equal [@invite.email]
      mail.body.encoded.must_match I18n.t('notifications.tournament_invitation.invited', :tournament => @tournament.name)
      mail.body.encoded.must_match @invite.code
    end
  end

  describe "#game_confirmation" do
    before do
      @game = create(:game)
      @player1 = create(:player)
      @player2 = create(:player)
      @user1 = @player1.user
      @user2 = @player2.user
      @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
    end

    it "must contain game details" do
      mail = Notifications.game_confirmation @user1, @game
      mail.subject.must_equal I18n.t('notifications.game_confirmation.subject', :game => @game.versus)
      mail.to.must_equal [@user1.email]
      mail.body.encoded.must_match @game.tournament.name
      mail.body.encoded.must_match @game.versus
    end
  end

  describe "#game_confirmed" do
    before do
      @game = create(:game)
      @player1 = create(:player)
      @player2 = create(:player)
      @user1 = @player1.user
      @user2 = @player2.user
      @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
    end

    it "must contain game details" do
      mail = Notifications.game_confirmed @user1, @game
      mail.subject.must_equal I18n.t('notifications.game_confirmed.subject', :game => @game.versus)
      mail.to.must_equal [@user1.email]
      mail.body.encoded.must_match @game.tournament.name
      mail.body.encoded.must_match @game.versus
    end
  end

  describe "#challenged" do
    before do
      @player1 = create(:player)
      @player2 = create(:player)
      @user1 = @player1.user
      @user2 = @player2.user
      @game = create(:challenge_game, :owner => @user1)
      @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
    end

    it "must contain challenge details" do
      mail = Notifications.challenged(@game.reload)
      mail.subject.must_equal I18n.t('notifications.challenged.subject', :tournament => @game.tournament.name)
      mail.to.must_equal [@game.defender.email]
      mail.body.encoded.must_match @game.tournament.name
      mail.body.encoded.must_match @game.challenger.name
      mail.body.encoded.must_match @game.defender.name
    end
  end

  describe "#commented" do
    before do
      @user = create(:user)
    end

    describe "games" do
      before do
        @comment = create(:game_comment)
        @game = @comment.commentable
        @tournament = @game.tournament
      end

      it "must contain comment details" do
        mail = Notifications.commented(@user, @comment)
        mail.subject.must_equal I18n.t('notifications.commented.subject', :commentable => @game.versus)
        mail.to.must_equal [@user.email]
        mail.body.encoded.must_match I18n.t('notifications.commented.commented', :name => @comment.user.name, :type => 'game')
        mail.body.encoded.must_match @comment.content
        mail.body.encoded.must_match @tournament.name
        mail.body.encoded.must_match @game.versus
      end
    end
  end

  describe "#invite_requested" do
    before do
      @invite_request = create(:invite_request)
      @tournament = @invite_request.tournament
    end

    it "must contain invite request details" do
      mail = Notifications.invite_requested(@invite_request)
      mail.subject.must_equal I18n.t('notifications.invite_requested.subject', :tournament => @tournament.name)
      mail.to.must_equal [@tournament.owner.email]
      mail.body.encoded.must_match I18n.t('notifications.invite_requested.invite_requested', :name => @invite_request.user.name, :tournament => @tournament.name)
    end
  end

  describe "#invite_request_accepted" do
    before do
      @invite_request = create(:invite_request)
      @tournament = @invite_request.tournament
    end

    it "must contain invite acceptance details" do
      mail = Notifications.invite_request_accepted(@invite_request)
      mail.subject.must_equal I18n.t('notifications.invite_request_accepted.subject', :tournament => @tournament.name)
      mail.to.must_equal [@invite_request.user.email]
      mail.body.encoded.must_match I18n.t('notifications.invite_request_accepted.invite_accepted', :name => @invite_request.user.name, :tournament => @tournament.name)
    end
  end

  describe "#championship_match" do
    before do
      @user = create(:user)
      @match = create(:match)
      @championship = @match.championship
      @tournament = @championship.tournament
      @other = @match.player1
    end

    it "must contain match details" do
      mail = Notifications.championship_match(@user, @match)
      mail.subject.must_equal I18n.t('notifications.championship_match.subject', tournament: @tournament.name)
      mail.to.must_equal [@user.email]
      mail.body.encoded.must_match I18n.t('notifications.championship_match.match', tournament: @tournament.name, other: @other.user.name)
    end
  end

  describe "#unconfirmed_games" do
    before do
      @game = create(:game)
      @player1 = create(:player)
      @player2 = create(:player)
      @user1 = @player1.user
      @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @game_rank2 = create(:game_rank, :game => create(:game), :player => @player1, :position => 1)
    end

    it "must contain game details" do
      mail = Notifications.unconfirmed_games(@user1, [@game_rank1, @game_rank2])
      mail.subject.must_equal I18n.t('notifications.unconfirmed_games.subject')
      mail.to.must_equal [@user1.email]
      mail.body.encoded.must_match @game_rank1.game.tournament.name
      mail.body.encoded.must_match @game_rank1.game.versus
      mail.body.encoded.must_match @game_rank2.game.tournament.name
      mail.body.encoded.must_match @game_rank2.game.versus
    end
  end
end
