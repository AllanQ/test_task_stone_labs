class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @questions = scope_questions
    @category_parent_id =
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @answer = Answer
                .find_by(question_id: @question.id, user_id: current_user.id)
    @questions = scope_questions
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

  def scope_questions
    res = Question.all unless params[:type_questions].present? &&
                              params[:type_questions] != 'All questions'
    res = Question.joins_answers(current_user.id, true).group('questions.id') \
                       if params[:type_questions] == 'Questions with answers'
    res = Question.joins_answers(current_user.id, false).group('questions.id') \
                       if params[:type_questions] == 'Questions without answers'
    res
  end
end
