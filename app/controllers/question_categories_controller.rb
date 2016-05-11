class QuestionCategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @category = QuestionCategory.find(params[:id])
    @questions = Question.scope_questions(params[:type_questions],
                                          current_user.id,
                                          params[:id]).page params[:page]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @question_category.destroy
    respond_to do |format|
      format.html { redirect_to questions_path }
      format.js
    end
  end
end
