class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.belongs_to :question, null: false, index: true
      t.belongs_to :user,     null: false, index: true
      t.text       :text,     null: false

      t.timestamps null: false
    end
  end
end
