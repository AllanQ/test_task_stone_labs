class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @type_questions = 'All questions'
    @type_questions = params[:type_questions] if params[:type_questions]
    @question_categories = QuestionCategory.main
    case @type_questions
      when 'All questions'
        @questions_all = Question.all
      when 'Questions with answers'
        @questions_with_answers = Question.joins(:answers).where(answers: { user_id: current_user.id })
      when 'Questions without answers'
        @questions_all = Question.all
        @questions_with_answers = Question.joins(:answers).where(answers: { user_id: current_user.id })
        @questions_without_answers = @questions_all - @questions_with_answers
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    category = QuestionCategory.find(@question.question_category_id)
    @question_category = category_full_name(category)
    @answer = Answer.find_by(question_id: @question.id, user_id: current_user.id)
    @type_questions = params[:type_questions]
    categories_array = QuestionCategory.main
    @questions_all = Question.all
    @questions = []
    case @type_questions
      when 'All questions'
        questions_all(categories_array)
      when 'Questions with answers'
        questions_with_answers(categories_array)
      when 'Questions without answers'
        questions_without_answers(categories_array)
    end
    i = @questions.index(@question)
    if i == @questions.length - 1
      @next_question = nil
      @previous_question = @questions[i-1]
    else
      if i == 0
        @next_question = @questions[i+1]
        @previous_question = nil
      else
        @next_question = @questions[i+1]
        @previous_question = @questions[i-1]
      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path
  end

  private

  def category_full_name(category)
    name = category.name
    parent_id = category.question_category_id
    while parent_id
      category = QuestionCategory.find(parent_id)
      parent_name = category.name
      name = "#{parent_name}->#{name}"
      parent_id = category.question_category_id
    end
    name
  end

  def questions_all(categories_array)
    categories_array.each do |category|
      @questions_all.each do |question|
        if question.question_category_id == category.id
          @questions << question
        end
      end
      categories_array = QuestionCategory.where(question_category_id: category.id)
      questions_all(categories_array)
    end
  end

  def questions_with_answers(categories_array)
    categories_array.each do |category|
      @questions_all.each do |question|
        if (question.question_category_id == category.id &&
            Answer.find_by(question_id: question.id, user_id: current_user.id))
          @questions << question
        end
      end
      categories_array = QuestionCategory.where(question_category_id: category.id)
      questions_with_answers(categories_array)
    end
  end

  def questions_without_answers(categories_array)
    categories_array.each do |category|
      @questions_all.each do |question|
        if (question.question_category_id == category.id &&
            !Answer.find_by(question_id: question.id, user_id: current_user.id))
          @questions << question
        end
      end
      categories_array = QuestionCategory.where(question_category_id: category.id)
      questions_without_answers(categories_array)
    end
  end
end
