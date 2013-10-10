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
      mail = Notifications.challenged(@game)
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
end
