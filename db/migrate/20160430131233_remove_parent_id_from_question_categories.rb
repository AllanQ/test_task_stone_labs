class RemoveParentIdFromQuestionCategories < ActiveRecord::Migration
  def change
    remove_column :question_categories, :parent_id
  end
end
