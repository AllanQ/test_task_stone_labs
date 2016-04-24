class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  scope :with_user_answers, -> (user_id) { joins(:answers)
                                         .where(answers: { user_id: user_id }) }
  scope :without_user_answers, -> (user_id) { joins("LEFT OUTER JOIN answers ON\
 answers.question_id = questions.id WHERE\
 ( answers.question_id NOT IN\
 ( SELECT question_id FROM answers WHERE user_id = #{user_id} ) ) OR\
 user_id IS NULL") }
  scope :next, -> (id) { where('id > ?', id) }
  scope :previous, -> (id) { where('id < ?', id) }


  def self.define_in_order(is_next, arr_questions, current_question_id)
    # :id категории текущего вопроса
    current_question_category_id = Question.find(current_question_id)
                                     .question_category_id
    array_params = [arr_questions, current_question_id,
                    current_question_category_id]
    is_next ? define_next(*array_params) : define_previous(*array_params)
  end

  def self.define_next(arr_questions, current_question_id,
                       current_question_category_id)
    if question = arr_questions.next(current_question_id).first
      if current_question_category_id == question.question_category_id
        # Если вопросы в одной категории - поиск завершен
        return question
      end
    end
    # Поиск в категории текущего вопроса
    return arr_questions
             .where(question_category_id: current_question_category_id)
             .next(current_question_id).first ||
      # Если нет - поиск в следующей категории
      search_in_next_category(arr_questions, current_question_category_id)
  end

  def self.define_previous(arr_questions, current_question_id,
                           current_question_category_id)
    if question = arr_questions.previous(current_question_id).last
      if current_question_category_id == question.question_category_id
        # Если вопросы в одной категории - поиск завершен
        return question
      end
    end
    # Поиск в категории текущего вопроса
    return arr_questions
             .where(question_category_id: current_question_category_id)
             .previous(current_question_id).last ||
      # Если нет - поиск в предыдущей категории
      search_in_previous_category(arr_questions, current_question_category_id)
  end

  def self.search_in_next_category(arr_questions, category_id,
    current_child_id = 0)
    return nil if category_id == nil && current_child_id == 0
    # Поиск категорий в заданной категории
    array_categories = QuestionCategory
                         .where(question_category_id: category_id)
                         .where('id > ?', current_child_id)
    if array_categories != []
      array_categories.each do |category|
        # Возвращаем результат или ищем ниже
        return arr_questions.where(question_category_id: category.id).first ||
          search_in_next_category(arr_questions, category.id)
      end
    end
    return nil if category_id == nil
    # Ищем выше в родительской категории(или QuestionCategory.main категории)
    search_in_next_category(
      arr_questions,
      QuestionCategory.find(category_id).question_category_id,
      category_id
    )
  end

  def self.search_in_previous_category(arr_questions, category_id)
    return nil if category_id == nil
    # Поиск категорий в родительской категории категории
    parent_id = QuestionCategory.find(category_id).question_category_id
    array_categories = QuestionCategory
                         .where(question_category_id: parent_id)
                         .where('id < ?', category_id)
    if array_categories != []
      # Поиск в подкатегориях
      res = search_previous_down(array_categories, arr_questions)
      return res if res
    end
    # Поиск впросов в родительской категории категории
    return arr_questions.where(question_category_id: parent_id).last ||
      # Иначе поиск выше
      search_in_previous_category(arr_questions, parent_id)
  end

  def self.search_previous_down(array_categories, arr_questions)
    (array_categories.length - 1).downto(0) do |i|
      # Поиск категорий
      arr = QuestionCategory.where(question_category_id: array_categories[i].id)
      res = search_previous_down(arr, arr_questions)
      return res if res
      # Поиск вопросов
      res = arr_questions
              .where(question_category_id: array_categories[i].id).last
      return res if res
    end
    nil
  end
end
