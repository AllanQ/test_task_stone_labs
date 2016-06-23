FactoryGirl.define do
  factory :question do
    association(:name) { |n| "Question Category №#{n}" }
    ancestry nil
  end
end