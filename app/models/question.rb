class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  scope :joins_answers, -> (user_id, is_answered) {
    select('ARRAY_AGG(answers.id) AS answer_id, questions.*')
    .joins("LEFT JOIN answers\
 ON answers.question_id = questions.id AND answers.user_id = #{user_id}")
    .where("answers.id IS#{is_answered ? ' NOT ' : ' '}NULL")
    .group('questions.id')
  }

  scope :order_by_categories, -> {
    order("idx(array(SELECT id\
 FROM (SELECT id, concat(ancestry || '/', id) AS sort_string\
 FROM question_categories ORDER BY sort_string ASC) AS category_id),\
 question_category_id), id")
  }

  #
  # SELECT *, concat(ancestry || '/', id) AS sort_string FROM question_categories ORDER BY sort_string ASC;
  # arr = QuestionCategory.select("*, concat(ancestry || '/', id) AS sort_string").order('sort_string').map{ |c| c.id }
  #
  # CREATE EXTENSION intarray;
  # SELECT * FROM questions ORDER BY idx(array[1, 5, 12, 14, 6, 7, 13, 8, 9, 10, 11, 15, 2, 3], question_category_id), id;
  # Question.all.order("idx(array#{arr}, question_category_id), id")
  #
  # SELECT * FROM questions ORDER BY idx(array(SELECT id FROM (SELECT id, concat(ancestry || '/', id) AS sort_string FROM question_categories ORDER BY sort_string ASC) AS category_id), question_category_id), id;
  #
  #
  # ???? SELECT id FROM questions ORDER BY idx(array[1, 27, 28, 5, 12, 14, 6, 7, 13, 8, 9, 10, 11, 15, 2, 3], question_category_id), id OVER lag(SELECT * FROM questions LIMIT 1)





  def self.scope_questions(type_questions = 'All questions', current_user_id)
    # arr = QuestionCategory.select("*, concat(ancestry || '/', id) AS sort_string")
    #                       .order('sort_string')
    #                       .map{ |c| c.id }
    res = Question.all.order_by_categories if type_questions == 'All questions'       # .order("idx(array#{arr}, question_category_id), id") \
    res = Question.joins_answers(current_user_id, true)
                  .group('questions.id')
                  .order_by_categories \
                                if type_questions == 'Questions with answers'   # .order("idx(array#{arr}, question_category_id), id") \
    res = Question.joins_answers(current_user_id, false)
                  .group('questions.id')
                  .order_by_categories \
                                if type_questions == 'Questions without answers' # .order("idx(array#{arr}, question_category_id), id") \
    res
  end

  def previous_question(type_questions, current_user_id)
    Question.scope_questions(type_questions, current_user_id)

  end

  def next_question(type_questions, current_user_id)
    Question.scope_questions(type_questions, current_user_id)
  end
end
