require 'rails_helper'

RSpec.describe QuestionCategory, type: :model do
  describe 'validations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(3) }
  end

  describe 'parent_enum' do
    it 'return array of names and ids of all\
 QuestionCategories except for the given one' do
      category1 = create(:QuestionCategory)
      category2 = create(:QuestionCategory, name: 'name2')
      category3 = create(:QuestionCategory, name: 'name3')
      expect(category1.parent_enum).to eq([['name2', 2], ['name3', 3]])
    end
  end

  describe 'return_question_category_full_name' do
    let(:category1) { create(:question_category, name: 'First') }
    let(:category2) { create(:question_category, name: 'Second',
                             ancestry: "#{category1.id}") }
    let(:category3) { create(:question_category, name: 'Third',
                             ancestry: "#{category1.id}/#{category2.id}") }
    it 'return full name of the category by id' do
      expect(QuestionCategory.return_question_category_full_name(category3.id))
        .to eq('First -> Second -> Third')
      expect(QuestionCategory.return_question_category_full_name(category1.id))
        .to eq('First')
    end
  end

end
