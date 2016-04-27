class RenameColumnQuestionCategoriesQuestionCategoryIdToParentId < ActiveRecord::Migration
  def change
    rename_column :question_categories, :question_category_id, :parent_id
  end
end
