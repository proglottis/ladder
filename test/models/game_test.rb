require "test_helper"

describe Game do
  before do
    @tournament = create(:tournament)
    @player1 = create(:player, :tournament => @tournament)
    @player2 = create(:player, :tournament => @tournament)
    @user1 = @player1.user
    @user2 = @player2.user
    @game = create(:unconfirmed_game, :tournament => @tournament, :owner => @user1)
    @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
    @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
    @game.reload
  end

  describe ".destroy" do
    it "must destroy descendent game ranks" do
      @game.destroy
      GameRank.where(:game_id => @game.id).count.must_equal 0
    end
  end

  describe ".participant" do
    it "must match participant" do
      Game.participant(@user1).must_include @game
      Game.participant(@user2).must_include @game
    end

    it "wont match nonparticipant" do
      @user = create(:user)
      Game.participant(@user).wont_include @game
    end
  end

  describe ".challenger" do
    describe "challenged" do
      before do
        @game.events.create! :state => "challenged"
      end

      it "must match games that the user owns" do
        Game.challenger(@user1).must_include @game
      end

      it "wont match games that the owner participated in" do
        Game.challenger(@user2).wont_include @game
      end

      it "wont match games that the user did not participant in" do
        Game.challenger(create(:user)).wont_include @game
      end
    end

    it "wont match non-challenged games" do
      Game.challenger(@user1).wont_include @game
      Game.challenger(@user2).wont_include @game
    end
  end

  describe ".defender" do
    describe "challenged" do
      before do
        @game.events.create! :state => "challenged"
      end

      it "wont match games that the user owns" do
        Game.defender(@user1).wont_include @game
      end

      it "must match games that the owner participated in" do
        Game.defender(@user2).must_include @game
      end

      it "wont match games that the user did not participant in" do
        Game.defender(create(:user)).wont_include @game
      end
    end

    it "wont match non-challenged games" do
      Game.defender(@user1).wont_include @game
      Game.defender(@user2).wont_include @game
    end
  end

  describe "#defender_response!" do
    before do
      @game.events.create!(state: 'challenged')
    end

    describe "won" do
      before do
        @game.response = "won"
      end

      it "must be unconfirmed" do
        @game.defender_response!
        @game.must_be :unconfirmed?
      end

      it "must mark the defender as winning" do
        @game.defender_response!
        @game.game_ranks.detect{ |gr| gr.position == 2 }.user.must_equal @user1
        @game.game_ranks.detect{ |gr| gr.position == 1 }.user.must_equal @user2
      end

      it "must mark own rank as confirmed" do
        @game.defender_response!
        @game.game_ranks.detect{ |gr| gr.user != @game.owner }.must_be :confirmed?
        @game.game_ranks.detect{ |gr| gr.user == @game.owner }.wont_be :confirmed?
      end
    end

    describe "lost" do
      before do
        @game.response = "lost"
      end

      it "must be unconfirmed" do
        @game.defender_response!
        @game.must_be :unconfirmed?
      end

      it "must mark the defender as losing" do
        @game.defender_response!
        @game.game_ranks.detect{ |gr| gr.position == 1 }.user.must_equal @user1
        @game.game_ranks.detect{ |gr| gr.position == 2 }.user.must_equal @user2
      end

      it "must mark own rank as confirmed" do
        @game.defender_response!
        @game.game_ranks.detect{ |gr| gr.user != @game.owner }.must_be :confirmed?
        @game.game_ranks.detect{ |gr| gr.user == @game.owner }.wont_be :confirmed?
      end
    end
  end

  describe "#confirm_user" do
    it "must confirm the users rank" do
      @game.confirm_user(@user1)
      @game_rank1.reload.confirmed?.must_equal true
    end

    it "wont confirm other users rank" do
      @game.confirm_user(@user1)
      @game_rank2.reload.confirmed?.wont_equal true
    end

    it "must return true when game is confirmed" do
      @game.confirm_user(@user1).wont_equal true
      @game.confirm_user(@user2).must_equal true
    end

    def confirm
      @game.confirm_user(@user1)
      @game.confirm_user(@user2)
    end

    describe "when the tournament has 'king of the hill' style ranking" do
      before do
        @player3 = create(:player, :position => 2, :tournament => @tournament)
        @player4 = create(:player, :position => 3, :tournament => @tournament)
        @game.tournament.update_attributes!(:ranking_type => 'king_of_the_hill')
      end

      describe "both positioned" do
        before do
          @player1.update_attributes!(:position => 1)
          @player2.update_attributes!(:position => 4)
        end

        describe "when the player with a higher rank wins" do
          it "keeps the rankings" do
            confirm
            @player1.reload.position.must_equal 1
            @player2.reload.position.must_equal 4
          end
        end

        describe "when the player with a higher rank loses" do
          before do
            @game_rank1.update_attributes!(:position => 2)
            @game_rank2.update_attributes!(:position => 1)
          end

          it "the lower ranked player takes their place and everyone between moves down" do
            confirm
            @player2.reload.position.must_equal 1
            @player1.reload.position.must_equal 2
            @player3.reload.position.must_equal 3
            @player4.reload.position.must_equal 4
          end
        end
      end

      describe "half positioned" do
        before do
          @player1.update_attributes!(:position => 1)
        end

        describe "when the player with position wins" do
          it "adds non-positioned player to the bottom of the ladder" do
            confirm
            @player1.reload.position.must_equal 1
            @player2.reload.position.must_equal 4
          end
        end

        describe "when the player with position loses" do
          before do
            @game_rank1.update_attributes!(:position => 2)
            @game_rank2.update_attributes!(:position => 1)
          end

          it "the non-positioned player takes their place and everyone moves down" do
            confirm
            @player2.reload.position.must_equal 1
            @player1.reload.position.must_equal 2
            @player3.reload.position.must_equal 3
            @player4.reload.position.must_equal 4
          end

        end
      end

      describe "not positioned" do
        it "sets both players positions at bottom of ladder in order" do
          confirm
          @player1.reload.position.must_equal 4
          @player2.reload.position.must_equal 5
        end
      end
    end

    describe "when the tournament has 'glicko' style ranking" do
      before do
        @player1.update_attributes!(:position => 1)
        @player2.update_attributes!(:position => 4)
      end

      describe "when the player with a higher rank wins" do
        it "keeps the rankings" do
          confirm
          @player1.reload.position.must_equal 1
          @player2.reload.position.must_equal 4
        end
      end

      describe "when the player with a higher rank loses" do
        before do
          @game_rank1.update_attributes!(:position => 2)
          @game_rank2.update_attributes!(:position => 1)
        end

        it "keeps the rankings" do
          confirm
          @player1.reload.position.must_equal 1
          @player2.reload.position.must_equal 4
        end
      end

    end

    describe "streaks" do
      it "must increment players winning/losing streaks when game is confirmed" do
        @player1.update_attributes :winning_streak_count => 5, :losing_streak_count => 0
        @player2.update_attributes :winning_streak_count => 0, :losing_streak_count => 5
        @game.confirm_user(@user1)
        @game.confirm_user(@user2)
        @player1.reload.winning_streak_count.must_equal 6
        @player1.reload.losing_streak_count.must_equal 0
        @player2.reload.winning_streak_count.must_equal 0
        @player2.reload.losing_streak_count.must_equal 6
      end

      it "must reset players winning/losing streaks when game is confirmed" do
        @player1.update_attributes :winning_streak_count => 0, :losing_streak_count => 5
        @player2.update_attributes :winning_streak_count => 5, :losing_streak_count => 0
        @game.confirm_user(@user1)
        @game.confirm_user(@user2)
        @player1.reload.winning_streak_count.must_equal 1
        @player1.reload.losing_streak_count.must_equal 0
        @player2.reload.winning_streak_count.must_equal 0
        @player2.reload.losing_streak_count.must_equal 1
      end

      it "must reset all streaks when game is a draw" do
        @game_rank2.update_attributes :position => 1
        @player1.update_attributes :winning_streak_count => 5, :losing_streak_count => 0
        @player2.update_attributes :winning_streak_count => 5, :losing_streak_count => 0
        @game.confirm_user(@user1)
        @game.confirm_user(@user2)
        @player1.reload.winning_streak_count.must_equal 0
        @player1.reload.losing_streak_count.must_equal 0
        @player2.reload.winning_streak_count.must_equal 0
        @player2.reload.losing_streak_count.must_equal 0
      end
    end
  end

  describe "#expire_challenge!" do
    describe "expired challenge" do
      before do
        travel_to(Time.new(2010))
        @game.events.create!(state: 'challenged')
        travel_to(Time.new(2010, 1, 8))
      end

      it "must confirm the game" do
        @game.expire_challenge!
        @game.must_be :confirmed?
      end

      it "must set the owner as the winner" do
        @game.expire_challenge!
        @game_rank1.reload.position.must_equal 1
        @game_rank2.reload.position.must_equal 2
      end
    end
  end

  describe "#current_state" do
    it 'should have initial state as unconfirmed' do
      @game.current_state.must_equal 'unconfirmed'
    end

    it 'should get latest state as set' do
      @game.events.create!(state: "confirmed")

      @game.current_state.must_equal 'confirmed'
    end
  end
end
