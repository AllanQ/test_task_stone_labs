class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  validates :question_id, :user_id, :text, presence: true
  validates_uniqueness_of :user_id, scope: :question_id
end
