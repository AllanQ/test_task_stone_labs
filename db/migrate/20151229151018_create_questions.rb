class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.belongs_to :question_category, index: true
      t.text       :text,               null: false, unique: true


      t.timestamps null: false
    end
  end
end
