class QuestionCategory < ActiveRecord::Base
  has_many   :children, class_name: 'QuestionCategory', dependent: :destroy
  belongs_to :parent,   class_name: 'QuestionCategory'

  has_many   :questions, dependent: :destroy

  validates_associated :questions
  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }

  has_ancestry

  def parent_enum
    QuestionCategory.where.not(id: id).map { |c| [ c.name, c.id ] }
  end

  scope :main, -> { where(question_category_id: nil) }

  def self.return_question_category_full_name(id)
    build_category_full_name(QuestionCategory.find(id))
  end

  # def has_questions?(questions)
  #   binding.pry
  #   return true if questions.where(question_category_id: id).length > 0
  #   QuestionCategory.find(id).children.map do |cat|
  #     binding.pry
  #     return true if questions.where(question_category_id: cat.id).length > 0
  #   end
  #   binding.pry
  #   false
  # end

  private

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
