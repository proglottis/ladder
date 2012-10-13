FactoryGirl.define do

  factory :user do
    name 'Bob Bobson'
    email 'bob@bobson.com'
  end

  factory :service do
    user
    provider 'developer'
    sequence(:uid) {|n| "user_#{n}"}
    name 'Bob Bobson'
    email 'bob@bobson.com'
  end

  factory :tournament do
    association :owner, :factory => :user
    sequence(:name) {|n| "Tournament #{n}"}
  end

  factory :rank do
    user
    tournament
    mu 25.0
    sigma 25.0 / 3.0
  end

  factory :invite do
    tournament
    email 'bob@bobson.com'
    sequence(:code) {|n| "code_#{n}"}
    expires_at { 1.day.from_now }
  end

end
