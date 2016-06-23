FactoryGirl.define do
  factory :user do
    name 'Test User Name'
    sequence(:email) { |n| "email#{n}@email.com"}
    encrypted_password 'testpassword'
    association(:user_status)
    admin false
    activated true
  end
end
