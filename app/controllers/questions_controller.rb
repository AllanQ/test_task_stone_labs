class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @questions = scope_questions
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @answer = Answer
                .find_by(question_id: @question.id, user_id: current_user.id)
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

  def scope_questions
    res = Question.all unless params[:type_questions].present? &&
                              params[:type_questions] != 'All questions'

    res = Question.with_user_answers(current_user.id) \
                          if params[:type_questions] == 'Questions with answers'
    res = Question.without_user_answers(current_user.id) \
                        if params[:type_questions] =='Questions without answers'

    # res = Question.joins(current_user.id).with_user_answers \
    #                       if params[:type_questions] == 'Questions with answers'
    # res = Question.joins(current_user.id).without_user_answers \
    #                     if params[:type_questions] =='Questions without answers'

    res
  end
end
