class QuestionCategory < ActiveRecord::Base
  has_many   :children, class_name: 'QuestionCategory', dependent: :destroy
  belongs_to :parent,   class_name: 'QuestionCategory'

  has_many   :questions, dependent: :destroy

  validates_associated :questions
  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }

  scope :main, -> { where(question_category_id: nil) }


  def self.return_question_category_full_name(id)
    build_category_full_name(QuestionCategory.find(id))
  end





  private

  def self.build_category_full_name(category)
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
