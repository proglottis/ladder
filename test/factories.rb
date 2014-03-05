FactoryGirl.define do

  factory :user, :aliases => [:owner] do
    name 'Bob Bobson'
    sequence(:email) {|n| "bob_#{n}@bobson.com"}
  end

  factory :service do
    user
    provider 'developer'
    sequence(:uid) {|n| "user_#{n}"}
    name 'Bob Bobson'
    email 'bob@bobson.com'
  end

  factory :tournament do
    owner
    sequence(:name) {|n| "Tournament #{n}"}

    factory :started_tournament do
      after :create do |tournament, evaluator|
        FactoryGirl.create :rating_period, :tournament => tournament
      end
    end
  end

  factory :invite do
    owner
    tournament
    email 'bob@bobson.com'
    sequence(:code) {|n| "code_#{n}"}
    expires_at { 1.day.from_now }
  end

  factory :invite_request do
    tournament
    user
  end

  factory :game do
    owner
    tournament

    factory :unconfirmed_game do
      after :create do |game, evaluator|
        game.events.create! state: 'unconfirmed'
      end
    end

    factory :confirmed_game do
      after :create do |game, evaluator|
        game.events.create! state: 'confirmed'
      end
    end

    factory :challenge_game do
      after :create do |game, evaluator|
        game.events.create! state: 'challenged'
      end
    end
  end

  factory :game_state do
    game
    state 'incomplete'
  end

  factory :game_rank do
    game
    player
    sequence(:position) {|n| n}
  end

  factory :page do
    content 'The content'
  end

  factory :player do
    tournament
    user
  end

  factory :rating_period do
    tournament
    period_at { 1.year.ago }
  end

  factory :rating do
    rating_period
    player
    rating Glicko2::DEFAULT_GLICKO_RATING
    rating_deviation Glicko2::DEFAULT_GLICKO_RATING_DEVIATION
    volatility Glicko2::DEFAULT_VOLATILITY
  end

  factory :game_comment, :class => "Comment" do
    association :commentable, :factory => :game
    content 'The content'
    user
  end

end
