class QuestionCategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def destroy
    @question_category.destroy
    redirect_to questions_path
  end
end
