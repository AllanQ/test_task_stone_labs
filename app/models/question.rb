class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  # CREATE EXTENSION intarray;

  scope :joins_answers, -> (user_id, is_answered) {
    query = <<-SQL
      LEFT OUTER JOIN answers
                   ON answers.question_id = questions.id
                  AND answers.user_id = #{user_id}
    SQL
    select('ARRAY_AGG(answers.id) AS answer_id, questions.*')
      .joins(query)
      .where("answers.id IS#{is_answered ? ' NOT ' : ' '}NULL")
      .group('questions.id')
  }
  scope :order_by_categories, -> {
    query = <<-SQL
      IDX(ARRAY(SELECT id
                  FROM  (SELECT id, concat(ancestry || '/', id) AS sort_string
                           FROM question_categories
                       ORDER BY sort_string ASC) AS category_id),
          question_category_id),
      id
    SQL
    order(query)
  }
  scope :next_or_previous_question, -> (user_id, is_answered, is_next, id) {
    sub_query = <<-SQL
      (          SELECT ARRAY_AGG(answers.id) AS answer_id, questions.*
                   FROM questions
        LEFT OUTER JOIN answers
                     ON answers.question_id = questions.id
                    AND answers.user_id = #{user_id}
                  WHERE answers.id IS#{is_answered ? ' NOT ' : ' '}NULL
               GROUP BY questions.id
      ) AS scope_questions
    SQL
    query = <<-SQL
      SELECT *
        FROM (SELECT *,
                     #{is_next ? 'LAG' : 'LEAD'}(id) OVER (
                       ORDER BY IDX(array(SELECT id
                                            FROM  (SELECT id,
                                                          CONCAT(
                                                            ancestry || '/',
                                                            id
                                                          ) AS sort_string
                                                     FROM question_categories
                                                 ORDER BY sort_string ASC)
                                              AS category_id),
                                     question_category_id),
                                id
                     )
                FROM #{is_answered == nil ? 'questions' : sub_query})
          AS next_or_previous_questions
       WHERE #{is_next ? 'lag' : 'lead'} = #{id}
    SQL
    find_by_sql(query)
  }

  def self.scope_questions(type_questions = 'All questions', current_user_id)
    res = Question.all if type_questions == 'All questions'
    res = Question.joins_answers(current_user_id, true)
            .group('questions.id') \
                       if type_questions == 'Questions with answers'
    res = Question.joins_answers(current_user_id, false)
            .group('questions.id') \
                       if type_questions == 'Questions without answers'
    res
  end

  def self.define_question(type_questions, current_user_id, id, is_next)
    is_answered = nil   if type_questions == 'All questions'
    is_answered = true  if type_questions == 'Questions with answers'
    is_answered = false if type_questions == 'Questions without answers'
    Question.next_or_previous_question(current_user_id, is_answered, is_next, id)
  end
end
