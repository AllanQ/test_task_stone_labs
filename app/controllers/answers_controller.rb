class AnswersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def form
    @question_id = answer_params[:question_id]
    @answer = Answer.where(user_id: current_user.id).find_by(question_id: @question_id)
    respond_to do |format|
      format.html { render :layout => false }
      # format.js
    end
  end

  def answerid
    @question_id = answer_params[:question_id]
    @answer = Answer.where(user_id: current_user.id).find_by(question_id: @question_id)
    respond_to do |format|
      format.html { render :layout => false }
      # format.js { render :layout => false }
    end
  end

  def create
    @question = Question.find(answer_params[:question_id])
    @answer.user_id = current_user.id
    if @answer.save
      redirect_to questions_path
    else
      @question = Question.find(answer_params[:question_id])
      render 'questions/show'
    end
  end

  def update
    if @answer.update_attributes(answer_params)
      redirect_to questions_path, status: 303
    else
      @question = Question.find(@answer.question_id)
      render 'questions/show'
    end
  end

  def destroy
    @answer.destroy
    redirect_to questions_path, status: 303
  end

  private

  def answer_params
    params.require(:answer).permit(:text, :question_id)
  end
end
