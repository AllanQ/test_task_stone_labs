class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  def self.return_type_questions(quest_type)
    quest_type ? quest_type : 'All questions'
  end

  def self.array_questions(quest_type, user_id)
    case quest_type
    when 'All questions'
      Question.all
    when 'Questions with answers'
      Question.joins(:answers).where(answers: { user_id: user_id })
    when 'Questions without answers'
      without_answers(user_id)
    end
  end

  def self.without_answers(user_id)
    sql = <<-SQL
      SELECT questions.* FROM questions
      WHERE NOT EXISTS
        (SELECT id FROM answers WHERE answers.user_id = #{user_id} AND
        answers.question_id = questions.id);
    SQL
    find_by_sql(sql)
  end

end
