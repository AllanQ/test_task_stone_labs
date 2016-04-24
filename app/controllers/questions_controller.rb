class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @questions = array_questions(params[:type_questions], current_user.id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @answer = Answer
                .find_by(question_id: @question.id, user_id: current_user.id)
    array_params = [@question.id, params[:type_questions], current_user.id]
    if params[:previous_question_id]
      @previous_question = Question.find(params[:previous_question_id])
    else
      @previous_question = define_previous_question(*array_params)
    end
    if params[:next_question_id]
      @next_question = Question.find(params[:next_question_id])
    else
      @next_question = define_next_question(*array_params)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_path }
      format.js
    end
  end

  def define_previous_question(current_question_id, type_questions, user_id)
    # Отображаемый список вопросов
    questions_scope = array_questions(type_questions, user_id)
    # :id категории текущего вопроса
    current_question_category_id = Question.find(current_question_id)
                                     .question_category_id
    # Предыдущий вопрос по :id в этом списке
    if previous_question = questions_scope
                             .where('id < ?', current_question_id).last
      # binding.pry
      # :id его категории
      previous_question_category_id = previous_question.question_category_id
      # Сравнение категорий
      if current_question_category_id == previous_question_category_id
        # binding.pry
        # Если вопросы в одной категории - поиск завершен
        return previous_question
      end
    end
    # binding.pry
    # Поиск в категории текущего вопроса
    return questions_scope
             .where(question_category_id: current_question_category_id)
             .where('id < ?', current_question_id).last ||
      # binding.pry
      # Если нет - поиск в следующей категории
      search_in_previous_category(questions_scope, current_question_category_id)
  end

  def define_next_question(current_question_id, type_questions, user_id)
    # Отображаемый список вопросов
    questions_scope = array_questions(type_questions, user_id)
    # :id категории текущего вопроса
    current_question_category_id = Question.find(current_question_id)
                                     .question_category_id
    # Следующий вопрос по :id в этом списке
    if next_question = questions_scope
                      .where('id > ?', current_question_id).first   #.next(current_question_id)
      # binding.pry
      # :id его категории
      next_question_category_id = next_question.question_category_id
      # Сравнение категорий
      if current_question_category_id == next_question_category_id
        # binding.pry
        # Если вопросы в одной категории - поиск завершен
        return next_question
      end
    end
    # binding.pry
    # Поиск в категории текущего вопроса
    return questions_scope
             .where(question_category_id: current_question_category_id)
             .where('id > ?', current_question_id).first ||        # .next(current_question_id)
      # binding.pry
      # Если нет - поиск в следующей категории
      search_in_next_category(questions_scope, current_question_category_id)
  end

  private

  def array_questions(type_questions, user_id)
    type_questions ||= 'All questions'
    case type_questions
    when 'All questions'
      Question.all
    when 'Questions with answers'
      Question.joins(:answers).where(answers: { user_id: user_id })
    when 'Questions without answers'
      Question.joins("LEFT OUTER JOIN answers ON\
 answers.question_id = questions.id WHERE\
 ( answers.question_id NOT IN\
 ( SELECT question_id FROM answers WHERE user_id = #{user_id} ) ) OR\
 user_id IS NULL")
    end
  end

  def search_in_previous_category(questions_scope, category_id)
    return nil if category_id == nil
    # Поиск категорий в родительской категории категории
    parent_id = QuestionCategory.find(category_id).question_category_id
    array_categories = QuestionCategory
                         .where(question_category_id: parent_id)
                         .where('id < ?', category_id)
    if array_categories != []
      # Поиск в подкатегориях
      res = search_previous_down(array_categories, questions_scope)
      return res if res
    end
    # Поиск впросов в родительской категории категории
    return questions_scope.where(question_category_id: parent_id).last ||
      # Иначе поиск выше
      search_in_previous_category(questions_scope, parent_id)
  end

  def search_previous_down(array_categories, questions_scope)
    (array_categories.length - 1).downto(0) do |i|
      # Поиск категорий
      arr = QuestionCategory.where(question_category_id: array_categories[i].id)
      res = search_previous_down(arr, questions_scope)
      return res if res
      # Поиск вопросов
      res = questions_scope
               .where(question_category_id: array_categories[i].id).last
      return res if res
    end
    nil
  end

  def search_in_next_category(questions_scope, category_id,
                              current_child_id = 0)
    return nil if category_id == nil && current_child_id == 0
    # Поиск категорий в заданной категории
    array_categories = QuestionCategory
                         .where(question_category_id: category_id)
                         .where('id > ?', current_child_id)
    if array_categories != []
      array_categories.each do |category|
        # Возвращаем результат или ищем ниже
        return questions_scope.where(question_category_id: category.id).first ||
          search_in_next_category(questions_scope, category.id)
      end
    end
    return nil if category_id == nil
    # Ищем выше в родительской категории(или QuestionCategory.main категории)
    search_in_next_category(
      questions_scope,
      QuestionCategory.find(category_id).question_category_id,
      category_id
    )
  end
end
