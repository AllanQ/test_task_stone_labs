class QuestionCategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def destroy
    @question_category.destroy
    respond_to do |format|
      format.html { redirect_to questions_path }
      format.js
    end
  end
end
