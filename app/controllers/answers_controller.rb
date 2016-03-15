class AnswersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @question = Question.find(answer_params[:question_id])
    @answer.user_id = current_user.id
    if @answer.save
      redirect_to questions_path#, alert: "Answer saved!"
    else
      # flash[:alert] = "Answer NOT saved!"
      @question = Question.find(answer_params[:question_id])
      render 'questions/show'
    end
  end

  def update
    if @answer.update_attributes(answer_params)
      redirect_to questions_path, status: 303#, alert: "Answer chanched!"
    else
      # flash[:alert] = "Answer NOT saved!"
      @question = Question.find(@answer.question_id)
      render 'questions/show'
    end
  end

  def destroy
    @answer.destroy
    redirect_to questions_path, status: 303#, alert: "Answer deleted!"
  end

  private

  def answer_params
    params.require(:answer).permit(:text, :question_id)
  end
end
