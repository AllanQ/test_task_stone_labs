class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  # scope :joins_answers, -> { joins(:answers) }
  # scope :with_user_answ, -> { where(answers: { user_id: user_id }) }
  # #scope :without, -> {  }
  # scope :next, -> (id) { where('id > ?', id).first }
  # scope :previous, -> (id) { where('id < ?', id).last }
  #
  #
  # def self.next(current_question_id, category_id, type_questions, user_id, which)
  #   case type_questions
  #   when 'All questions'
  #     questions_scope = Question.all
  #     next_question = questions_scope.next(current_question_id)
  #
  #     current_question_category_id = Question.find(current_question_id).question_category_id
  #     next_question_category_id = next_question.question_category_id
  #     if current_question_category_id == next_question_category_id
  #       return next_question
  #     else
  #       return
  #         questions_scope
  #           .where(question_category_id: current_question_category_id)
  #           .next(current_question_id) ||
  #           questions_scope
  #             .where(question_category_id: QuestionCategory.next(current_question_category_id).id).first ||
  #
  #     end
  #
  #
  #
  #
  #   when 'Questions with answers'
  #     Question.joins_answers.with_user_answ.next
  #
  #   when 'Questions without answers'
  #     without_answers(user_id).next
  #
  #   end
  #
  # end
  #
  # def self.serach_questions_in_category()
  #
  # end



  def self.next_and_previous(current_question, type_questions, user_id, which)
    main_categories_array = QuestionCategory.main
    array_questions = define_questions_array(type_questions,
                                             main_categories_array, user_id)
    case which
    when 'previous'
      nearest(current_question, array_questions)[0]
    when 'next'
      nearest(current_question, array_questions)[1]
    else
      raise("Error in button-link to next or previous question.\
 which = #{which}")
    end
  end

  private

  def self.define_questions_array(type_questions, main_categories_array,
                                  user_id)
    case type_questions
    when 'All questions'
      proc = proc { |question, category|
        question.question_category_id == category.id }
      sort_questions(main_categories_array, proc)
    when 'Questions with answers'
      proc = proc { |question, category|
        (question.question_category_id == category.id &&
          Answer.find_by(question_id: question.id,
                         user_id: user_id)) }
      sort_questions(main_categories_array, proc)
    when 'Questions without answers'
      proc = proc { |question, category|
        (question.question_category_id == category.id &&
          !Answer.find_by(question_id: question.id,
                          user_id: user_id)) }
      sort_questions(main_categories_array, proc)
    end
  end

  def self.sort_questions(main_categories_array, proc)
    array_questions = []
    array_questions_all = Question.all
    main_categories_array.each do |category|
      array_questions_all.each do |question|
        condition = proc.call(question, category)
        if condition
          array_questions << question
        end
      end
      categories_array = QuestionCategory
        .where(question_category_id: category.id)
      array_questions += sort_questions(categories_array, proc)
    end
    array_questions
  end

  def self.nearest(current_question, array_questions)
    i = array_questions.index(current_question)
    if i == array_questions.length - 1
      next_question = nil
      previous_question = array_questions[i-1]
    else
      if i == 0
        next_question = array_questions[i+1]
        previous_question = nil
      else
        next_question = array_questions[i+1]
        previous_question = array_questions[i-1]
      end
    end
    [previous_question, next_question]
  end

end
