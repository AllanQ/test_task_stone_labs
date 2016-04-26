class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  scope :with_user_answers,    -> (user_id) {
    find_by_sql("SELECT ARRAY_AGG(answers.id) AS answer_id, questions.*\
 FROM questions LEFT OUTER JOIN answers ON answers.question_id = questions.id\
 AND answers.user_id = #{user_id} WHERE answers.id IS NULL\
 GROUP BY questions.id")
  }
  scope :without_user_answers, -> (user_id) {
    find_by_sql("SELECT ARRAY_AGG(answers.id) AS answer_id, questions.*\
 FROM questions LEFT OUTER JOIN answers ON answers.question_id = questions.id\
 AND answers.user_id = #{user_id} WHERE answers.id IS NOT NULL\
 GROUP BY questions.id")
  }


  # ancestry

  # def next_question
  #   Question.where("id > #{id}")
  #   .order(:question_category_id, :id)
  #   .first
  # end
  #
  # def previous_question
  #   Question.where("id < #{id}")
  #   .order(:question_category_id, :id)
  #   .first
  # end
end
