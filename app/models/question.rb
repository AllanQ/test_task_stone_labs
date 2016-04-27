class Question < ActiveRecord::Base

  # require_relative '../../app/controllers/questions_controller'

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

  def next_question(array_questions)
    res = array_questions.where(question_category_id: question_category_id)
                         .where("id > #{id}")
                         .order(:id)
                         .first
    return res if res
    array_category_sorted = QuestionCategory
      .sort_by_ancestry(QuestionCategory.all)
    index_category_current_question = array_category_sorted
      .index(QuestionCategory.find(question_category_id))
    array_category_sorted[(index_category_current_question + 1)..-1]
      .map do |category|
      res = array_questions.where(question_category_id: category.id)
                           .order(:id).first
      return res if res
    end
    res
  end

  def previous_question(array_questions)
    res = array_questions.where(question_category_id: question_category_id)
            .where("id < #{id}")
            .order(:id)
            .last
    unless res
      array_category_sorted = QuestionCategory
        .sort_by_ancestry(QuestionCategory.all)
      index_category_current_question = array_category_sorted
        .index(QuestionCategory.find(question_category_id))
      array_category_sorted[0..(index_category_current_question - 1)].reverse
        .map do |category|
        res = array_questions.where(question_category_id: category.id)
                             .order(:id).last
        break if res
      end
    end
    res
  end
end
