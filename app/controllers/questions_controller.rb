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
    @next_question     = define_question(params[:next_question_id],     true)
    @previous_question = define_question(params[:previous_question_id], false)
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

  def array_questions(type_questions, user_id)
    type_questions ||= 'All questions'
    return Question.all                           if type_questions ==
                                                                 'All questions'
    return Question.with_user_answers(user_id)    if type_questions ==
                                                        'Questions with answers'
    return Question.without_user_answers(user_id) if type_questions ==
                                                     'Questions without answers'
  end

  def define_question(id, is_next)
    if id
      return Question.find(id)
    else
      arr_questions = array_questions(params[:type_questions], current_user.id)
      Question.define_in_order(is_next, arr_questions, @question.id)
    end
  end
end
