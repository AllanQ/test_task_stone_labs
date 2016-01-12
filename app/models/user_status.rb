class UserStatus < ActiveRecord::Base
  has_many  :users

  validates_associated :users
  validates :name, presence: true, uniqueness: true
end
