FactoryGirl.define do
  factory :question do
    association(:question)
    association(:user)
    sequence(:text) { |n| "Answer №#{n}" }
  end
end