FactoryGirl.define do
  factory :agent do
    name  "Dan"
    email "dan@example.com"
    password "secret"

    factory :another_agent do
      name  "Lanny"
      email "lanny@example.com"
    end
  end
end
