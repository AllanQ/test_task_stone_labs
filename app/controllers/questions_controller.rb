class QuestionsController < ApplicationController
  require_relative '../../app/models/question'

  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @type_questions = Question.return_type_questions(params[:type_questions])
    @user_id = current_user.id
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    category = QuestionCategory.find(@question.question_category_id)
    @question_category = category_full_name(category)
    @answer = Answer.find_by(question_id: @question.id,
                             user_id: current_user.id)
    @type_questions = params[:type_questions]
    categories_array = QuestionCategory.main
    @questions_all = Question.all
    @questions = []
    case @type_questions
      when 'All questions'
        questions(categories_array) { |question, category|
          question.question_category_id == category.id
        }
      when 'Questions with answers'
        questions(categories_array) { |question, category|
          (question.question_category_id == category.id &&
            Answer.find_by(question_id: question.id, user_id: current_user.id))
        }
      when 'Questions without answers'
        questions(categories_array){ |question, category|
          (question.question_category_id == category.id &&
            !Answer.find_by(question_id: question.id,
            user_id: current_user.id))
        }
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
    respond_to do |format|
      format.html { redirect_to questions_path }
      format.js
    end
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

  def questions(categories_array)
    categories_array.each do |category|
      @questions_all.each do |question|
        if yield
          @questions << question
        end
      end
      categories_array = QuestionCategory
        .where(question_category_id: category.id)
      questions(categories_array){yield}
    end
  end
end
