class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if Question.exists?() && QuestionCategory.exists?()
      @questions = Question
                     .scope_questions(params[:type_questions], current_user.id)
                     .order_by_categories
                     .page(params[:page])
                     .per(params[:per])
    else
      @questions = []
    end
    @length_questions = @questions.length
    @index_questions = 0
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
end
