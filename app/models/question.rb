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
  # scope :joins_answers_from_category, -> (user_id, is_answered, category_id) {
  #   joins_answers(user_id, is_answered)
  #   .where("question_category_id = #{category_id}")
  # }
  # scope :previous_questions, -> (id) { where("questions.id < #{id}")
  #                                     .order('questions.id') }
  # scope :next_questions,     -> (id) { where("questions.id > #{id}")
  #                                     .order('questions.id') }


  #
  # arr = QuestionCategory.select("*, concat(ancestry || '/', id) AS sort_string").order('sort_string').map{ |c| c.id }
  #
  # Question.all.order("question_category_id, array#{arr}")
  #
  #
  #
  # CREATE EXTENSION intarray;
  # SELECT text FROM questions ORDER BY idx(array[1, 5, 12, 14, 6, 7, 13, 8, 9, 10, 11, 15, 2, 3], question_category_id), id;
  #
  #
  #
  #
  #


  def self.scope_questions(type_questions = 'All questions', current_user_id)
    arr = QuestionCategory.select("*, concat(ancestry || '/', id) AS sort_string")
                          .order('sort_string')
                          .map{ |c| c.id }
    res = Question.all.order("question_category_id, array#{arr}") \
                       if type_questions == 'All questions'
    res = Question.joins_answers(current_user_id, true)
                  .group('questions.id')
                  .order("question_category_id, array#{arr}") \
                       if type_questions == 'Questions with answers'
    res = Question.joins_answers(current_user_id, false)
                  .group('questions.id')
                  .order("question_category_id, array#{arr}") \
                       if type_questions == 'Questions without answers'
    res
  end

  def previous_question(type_questions, current_user_id)
    questions_scope = scope_questions(type_questions, current_user_id)
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

  def next_question(type_questions, current_user_id)
    questions_scope = scope_questions(type_questions, current_user_id)
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










  #
  # def self.scope_questions_by_category(type_questions = 'All questions', user_id,
  #                          category_id)
  #   res = Question.where(question_category_id: category_id) if
  #     type_questions == 'All questions'
  #   res = Question.joins_answers_from_category(user_id, true, category_id) if
  #     type_questions == 'Questions with answers'
  #   res = Question.joins_answers_from_category(user_id, false, category_id) if
  #     type_questions == 'Questions without answers'
  #   res
  # end
  #
  # def previous_question_by_category(type_questions, user_id)
  #   res = previous_question_in_category(type_questions, user_id, id,
  #                                       question_category_id)
  #   return res if res
  #   array_category_sorted           = QuestionCategory.sort_by_ancestry
  #   index_category_current_question = array_category_sorted
  #     .index(QuestionCategory.find(question_category_id))
  #   array_category_sorted[0..(index_category_current_question - 1)].reverse
  #     .map do |category|
  #     res = last_question_in_category(type_questions, user_id, category.id)
  #     return res if res
  #   end
  #   res
  # end
  #
  # def next_question_by_category(type_questions, user_id)
  #   res = next_question_in_category(type_questions, user_id, id,
  #                                       question_category_id)
  #   return res if res
  #   array_category_sorted           = QuestionCategory.sort_by_ancestry
  #   index_category_current_question = array_category_sorted
  #     .index(QuestionCategory.find(question_category_id))
  #   array_category_sorted[(index_category_current_question + 1)..-1]
  #     .map do |category|
  #     res = first_question_in_category(type_questions, user_id, category.id)
  #     return res if res
  #   end
  #   res
  # end
  #
  # private
  #
  # def previous_question_in_category(type_questions, user_id, question_id,
  #                                   question_category_id)
  #   case type_questions
  #     when 'All questions'
  #       Question.where(question_category_id: question_category_id)
  #         .previous_questions(question_id)
  #         .last
  #     when 'Questions with answers'
  #       Question.joins_answers_from_category(user_id, true, question_category_id)
  #         .previous_questions(question_id)
  #         .last
  #     when 'Questions without answers'
  #       Question.joins_answers_from_category(user_id, false, question_category_id)
  #         .previous_questions(question_id)
  #         .last
  #   end
  # end
  #
  # def next_question_in_category(type_questions, user_id, question_id,
  #                               question_category_id)
  #   case type_questions
  #     when 'All questions'
  #       Question.where(question_category_id: question_category_id)
  #         .next_questions(question_id)
  #         .first
  #     when 'Questions with answers'
  #       Question.joins_answers_from_category(user_id, true, question_category_id)
  #         .next_questions(question_id)
  #         .first
  #     when 'Questions without answers'
  #       Question.joins_answers_from_category(user_id, false, question_category_id)
  #         .next_questions(question_id)
  #         .first
  #   end
  # end
  #
  # def last_question_in_category(type_questions, user_id, question_category_id)
  #   case type_questions
  #     when 'All questions'
  #       Question.where(question_category_id: question_category_id)
  #         .order('questions.id')
  #         .last
  #     when 'Questions with answers'
  #       Question.joins_answers_from_category(user_id, true, question_category_id)
  #         .order('questions.id')
  #         .last
  #     when 'Questions without answers'
  #       Question.joins_answers_from_category(user_id, false, question_category_id)
  #         .order('questions.id')
  #         .last
  #   end
  # end
  #
  # def first_question_in_category(type_questions, user_id, question_category_id)
  #   case type_questions
  #   when 'All questions'
  #     Question.where(question_category_id: question_category_id)
  #             .order('questions.id')
  #             .first
  #   when 'Questions with answers'
  #     Question.joins_answers_from_category(user_id, true, question_category_id)
  #             .order('questions.id')
  #             .first
  #   when 'Questions without answers'
  #     Question.joins_answers_from_category(user_id, false, question_category_id)
  #             .order('questions.id')
  #             .first
  #   end
  # end
  #
end
