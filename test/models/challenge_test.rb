require "test_helper"

describe Challenge do
  describe ".create" do
    before do
      @defender = create(:defender)
      @tournament = create(:tournament)
    end

    it "wont allow defender to be challenged more than once" do
      @challenge = @tournament.challenges.create(:defender => @defender, :challenger => create(:challenger))
      @challenge.errors.size.must_equal 0
      @challenge = @tournament.challenges.create(:defender => @defender, :challenger => create(:challenger))
      @challenge.errors.size.must_equal 1
    end

    it "wont allow defender to be the same as the challenger" do
      @challenge = @tournament.challenges.create(:defender => @defender, :challenger => @defender)
      @challenge.errors.size.must_equal 1
    end

    it "must generate expiry when blank" do
      @challenge = build(:challenge)
      @challenge.expires_at = nil
      @challenge.save
      @challenge.expires_at.wont_equal nil
    end
  end

  describe ".active" do
    before do
      @challenge_active = create(:challenge, :game => nil)
      @challenge_inactive = create(:challenge, :game => create(:game))
    end

    it "must match an active tournaments" do
      Challenge.active.must_include @challenge_active
    end

    it "wont match an inactive tournaments" do
      Challenge.active.wont_include @challenge_inactive
    end
  end

  describe ".defending" do
    before do
      @challenge = create(:challenge)
    end

    it "must match when user is defending" do
      Challenge.defending(@challenge.defender).must_include @challenge
    end

    it "wont match when user is not defending" do
      Challenge.defending(@challenge.challenger).wont_include @challenge
    end
  end

  describe ".challenging" do
    before do
      @challenge = create(:challenge)
    end

    it "must match when user is defending" do
      Challenge.challenging(@challenge.challenger).must_include @challenge
    end

    it "wont match when user is not defending" do
      Challenge.challenging(@challenge.defender).wont_include @challenge
    end
  end

  describe "#respond!" do
    before do
      @challenge = create(:challenge)
    end

    it "must generate a game when defender won" do
      @challenge.response = 'won'
      @challenge.respond!
      @challenge.game.wont_equal nil
      @challenge.game.game_ranks.first.user.must_equal @challenge.defender
      @challenge.game.game_ranks.first.position.must_equal 1
      @challenge.game.game_ranks.last.user.must_equal @challenge.challenger
      @challenge.game.game_ranks.last.position.must_equal 2
    end

    it "must generate a game when defender lost" do
      @challenge.response = 'lost'
      @challenge.respond!
      @challenge.game.wont_equal nil
      @challenge.game.game_ranks.first.user.must_equal @challenge.challenger
      @challenge.game.game_ranks.first.position.must_equal 1
      @challenge.game.game_ranks.last.user.must_equal @challenge.defender
      @challenge.game.game_ranks.last.position.must_equal 2
    end

    it "wont generate a game when response is unknown" do
      @challenge.response = 'unknown'
      @challenge.respond!
      @challenge.game.must_equal nil
    end

    it "must send a confirmation email to loser" do
      @challenge.response = 'won'
      @challenge.respond!
      ActionMailer::Base.deliveries.length.must_equal 1
      email = ActionMailer::Base.deliveries.first
      email.to.must_equal [@challenge.challenger.email]
    end
  end

  describe "#build_default_game" do
    before do
      @challenge = create(:challenge)
      @game = @challenge.build_default_game
    end

    it "must build a game" do
      @game.wont_equal nil
      @game.new_record?.must_equal true
    end

    it "must build game ranks" do
      @game.game_ranks.length.must_equal 2
    end

    it "must build winning rank for challenger" do
      @game.game_ranks.first.position.must_equal 1
      @game.game_ranks.first.user.must_equal @challenge.challenger
    end

    it "must build losing rank for defender" do
      @game.game_ranks.last.position.must_equal 2
      @game.game_ranks.last.user.must_equal @challenge.defender
    end
  end
end
