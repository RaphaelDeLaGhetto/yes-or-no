FactoryGirl.define do
  factory :account do

    factory :admin do
      email 'daniel@example.com'
      password 'secret'
      password_confirmation 'secret'
      role 'admin'
    end

  end
end
