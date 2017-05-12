FactoryGirl.define do
  factory :agent do
    name  "Dan"
    email "dan@example.com"
    password "secret"
    trusted true

    factory :another_agent do
      name  "Lanny"
      email "lanny@example.com"
    end
  end
end
