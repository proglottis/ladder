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
  end

  factory :glicko2_rating, :aliases => [:rating] do
    user
    tournament
    rating Glicko2::DEFAULT_GLICKO_RATING
    rating_deviation Glicko2::DEFAULT_GLICKO_RATING_DEVIATION
    volatility Glicko2::DEFAULT_VOLATILITY
  end

  factory :invite do
    owner
    tournament
    email 'bob@bobson.com'
    sequence(:code) {|n| "code_#{n}"}
    expires_at { 1.day.from_now }
  end

  factory :game do
    tournament
  end

  factory :game_rank do
    game
    user
    sequence(:position) {|n| n}
  end

end
