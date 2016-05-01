class Question < ActiveRecord::Base

  # require_relative '../../app/controllers/questions_controller'

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

  def previous_question(questions_scope)
    res = questions_scope.where(question_category_id: question_category_id)
                         .where("questions.id < #{id}")
                         .order('questions.id')
                         .last
    return res if res
    array_category_sorted = QuestionCategory
      .sort_by_ancestry(QuestionCategory.all)
    index_category_current_question = array_category_sorted
      .index(QuestionCategory.find(question_category_id))
    array_category_sorted[0..(index_category_current_question - 1)].reverse
      .map do |category|
      res = questions_scope.where(question_category_id: category.id)
              .order(:id).last
      return res if res
    end
    res
  end

  def next_question(questions_scope)
    res = questions_scope.where(question_category_id: question_category_id)
                         .where("questions.id > #{id}")
                         .order('questions.id')
                         .first
    return res if res
    array_category_sorted = QuestionCategory
      .sort_by_ancestry(QuestionCategory.all)
    index_category_current_question = array_category_sorted
      .index(QuestionCategory.find(question_category_id))
    array_category_sorted[(index_category_current_question + 1)..-1]
      .map do |category|
      res = questions_scope.where(question_category_id: category.id)
                           .order(:id).first
      return res if res
    end
    res
  end
end
