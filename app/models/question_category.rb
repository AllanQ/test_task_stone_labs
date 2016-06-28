class QuestionCategory < ActiveRecord::Base
  has_many   :questions, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }

  has_ancestry

  # config/initializers/rails_admin.rb   config.model 'QuestionCategory'
  def parent_enum
    QuestionCategory.where.not(id: id).map { |c| [ c.name, c.id ] }
  end

  def self.return_question_category_full_name(id)
    build_category_full_name(QuestionCategory.find(id))
  end

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
