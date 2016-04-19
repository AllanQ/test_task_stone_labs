class User < ActiveRecord::Base
  belongs_to :user_status
  has_many   :answers, dependent: :destroy
  has_many   :questions, through: :answers

  validates_associated :questions
  validates :name, :email, :encrypted_password, presence: true
  validates :email, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable,              :validatable



end
