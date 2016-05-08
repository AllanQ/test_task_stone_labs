class QuestionCategory < ActiveRecord::Base
  has_many   :questions, dependent: :destroy

  validates_associated :questions
  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }

  has_ancestry

  def parent_enum
    QuestionCategory.where.not(id: id).map { |c| [ c.name, c.id ] }
  end

  scope :main, -> { where(question_category_id: nil) }
  scope :sort_by_ancestry, -> {
    select("*, concat(ancestry || '/', id) AS sort_string")
    .order('sort_string')
  }

  def has_questions?
    Question.where(question_category_id: id).length > 0
  end

  def has_questions_with_answers?(user_id)
    Question.where(question_category_id: id)
            .joins_answers(user_id, true)
            .length > 0
  end

  def has_questions_without_answers?(user_id)
    Question.where(question_category_id: id)
            .joins_answers(user_id, false)
            .length > 0
  end

  def has_descendants_questions_with_answers?(user_id)
    res = false
    QuestionCategory
      .find(id)
      .descendants
      .each do |category|
        if category.has_questions?
          return true if category.has_questions_with_answers?(user_id)
        end
      end
    res
  end

  def has_descendants_questions_without_answers?(user_id)
    res = false
    QuestionCategory
      .find(id)
      .descendants
      .each do |category|
      if category.has_questions?
        return true if category.has_questions_without_answers?(user_id)
      end
    end
    res
  end

  def self.return_question_category_full_name(id)
    build_category_full_name(QuestionCategory.find(id))
  end

  def self.build_category_full_name(category)
    if category.ancestors.length > 0
      ( category.ancestors
          .inject('') do |str, ancestor_category|
        "#{str} -> #{ancestor_category.name}"
      end +
        " -> #{category.name}" )[3..-1]
    else
      category.name
    end
  end
end
