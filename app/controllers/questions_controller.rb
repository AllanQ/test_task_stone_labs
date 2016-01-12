class QuestionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @question_categories = QuestionCategory.main
    @questions_all = Question.all
  end

  def with_answers
    @question_categories = QuestionCategory.main
    @questions_with_answers = Question.joins(:answers).where(answers: { user_id: current_user.id })
  end

  def without_answers
    @question_categories = QuestionCategory.main
    @questions_all = Question.all
    @questions_with_answers = Question.joins(:answers).where(answers: { user_id: current_user.id })
    @questions_without_answers = @questions_all - @questions_with_answers
  end

  def show
    category = QuestionCategory.find(@question.question_category_id)
    @question_category = category_full_name(category)
    @answer = Answer.find_by(question_id: @question.id, user_id: current_user.id)
  end

  def destroy
    @question.destroy
    redirect_to questions_path
  end

  private

  def category_full_name(category)
    name = category.name
    parent_id = category.question_category_id
    while parent_id
      category = QuestionCategory.find(parent_id)
      parent_name = category.name
      name = "#{parent_name}->#{name}"
      parent_id = category.question_category_id
    end
    name
  end
end
