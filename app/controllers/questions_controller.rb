class QuestionsController < ApplicationController
  require_relative '../../app/models/question'

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
    case type_questions
    when 'All questions'
      Question.all
    when 'Questions with answers'
      Question.joins(:answers).where(answers: { user_id: user_id })
    when 'Questions without answers'
      without_answers(user_id)
    end
  end

  def without_answers(user_id)
    sql = <<-SQL
      SELECT questions.* FROM questions
        WHERE NOT EXISTS
        (SELECT id FROM answers WHERE answers.user_id = #{user_id} AND
        answers.question_id = questions.id);
    SQL
    Question.find_by_sql(sql)
  end
end
