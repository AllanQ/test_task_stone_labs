class QuestionCategory < ActiveRecord::Base
  has_many   :children, class_name: 'QuestionCategory', dependent: :destroy
  belongs_to :parent,   class_name: 'QuestionCategory'

  has_many   :questions, dependent: :destroy

  validates_associated :questions
  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }

  scope :main, -> { where(question_category_id: nil) }


end
