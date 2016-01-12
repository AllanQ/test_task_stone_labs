class CreateQuestionCategories < ActiveRecord::Migration
  def change
    create_table :question_categories do |t|
      t.string     :name,               null: false, unique: true
      t.belongs_to :question_category, index: true

      t.timestamps null: false
    end
  end
end
