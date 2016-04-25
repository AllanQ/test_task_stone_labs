class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  scope :joins_answers, -> (user_id) {
    joins("SELECT answers.user_id, questions.* FROM questions\
 LEFT OUTER JOIN answers ON answers.question_id = questions.id\
 AND answers.user_id = #{user_id}")
  }
  scope :with_user_answers,    -> (user_id) {
    find_by_sql("SELECT answers.user_id, questions.* FROM questions\
 LEFT OUTER JOIN answers ON answers.question_id = questions.id\
 AND answers.user_id = #{user_id} WHERE answers.user_id IS NULL")
  }
  scope :without_user_answers, -> (user_id) {
    find_by_sql("SELECT answers.user_id, questions.* FROM questions\
 LEFT OUTER JOIN answers ON answers.question_id = questions.id\
 AND answers.user_id = #{user_id} WHERE answers.user_id IS NOT NULL")
  }

  # scope :with_user_answers,    -> { where('answers.user_id IS NULL') }
  # scope :without_user_answers, -> { where('answers.user_id IS NOT NULL') }

  # scope :with_user_answers,    -> { where(Answer.user_id == nil) }
  # scope :without_user_answers, -> { where(Answer.user_id != nil) }

 # scope :with_user_answers,    -> { find_by_sql('WHERE answers.user_id IS NULL') }
 # scope :without_user_answers, -> { find_by_sql('WHERE answers.user_id IS NOT NULL') }

  # scope :with_user_answers,    -> { find_by_sql('SELECT questions.* WHERE answers.user_id IS NULL') }
  # scope :without_user_answers, -> { find_by_sql('SELECT questions.* WHERE answers.user_id IS NOT NULL') }

  def next_question
    Question.where("id > #{id}")
    .order(:question_category_id, :id)
    .first
  end

  def previous_question
    Question.where("id < #{id}")
    .order(:question_category_id, :id)
    .first
  end
end
