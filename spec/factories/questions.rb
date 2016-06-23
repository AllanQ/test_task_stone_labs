FactoryGirl.define do
  factory :question do
    association(:question_category)
    sequence(:text) { |n| "Question №#{n}?" }
  end
end