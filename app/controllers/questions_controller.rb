class QuestionsController < ApplicationController
  require_relative '../../app/models/question'

  before_action :authenticate_user!
  load_and_authorize_resource

  def index
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
