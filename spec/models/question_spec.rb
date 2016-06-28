require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'validations' do
    it { should belong_to(:question_category) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should have_many(:users).through(:answers) }
    it { should validate_presence_of(:question_category_id) }
    it { should validate_presence_of(:text) }
    it { should validate_uniqueness_of(:text) }
    it { should validate_length_of(:text).is_at_least(3) }
  end

  describe 'scopes' do
    let(:category1) { create(:question_category) }
    let(:category2) { create(:question_category) }
    let(:user2) { create(:user, name: 'User2') }
    let(:user1) { create(:user, name: 'User1') }
    let(:user2) { create(:user, name: 'User2') }
    let(:question1) { create(:question, text: 'Q1?',
                             question_category: category2) }
    let(:question2) { create(:question, text: 'Q2?',
                             question_category: category1) }
    let(:question3) { create(:question, text: 'Q3?',
                             question_category: category1) }
    let(:question4) { create(:question, text: 'Q4?',
                             question_category: category2) }
    let(:answer2) { create(:answer, user: user1, question: question2) }
    let(:answer4) { create(:answer, user: user1, question: question4) }
    let(:answer3) { create(:answer, user: user2, question: question3) }
    describe 'joins_answers scope' do
      it 'returns questions with answers by a user' do
        expect(Question.joins_answers(user1.id, true).map{ |q| q.text })
          .to eq(['Q2?', 'Q4?'])
      end
      it 'returns questions without answers by a user' do
        expect(Question.joins_answers(user1.id, false).map{ |q| q.text })
          .to eq(['Q1?', 'Q3?'])
      end
    end
    describe 'order_by_categories scope' do
      it 'orders questions by categories ids' do
        expect(Question.order_by_categories.map{ |q| q.text })
          .to eq(['Q2?', 'Q3?','Q1?', 'Q4?'])
      end
    end
    describe 'next_or_previous_question scope' do
      it 'finds next question' do
        expect(Question
                 .next_or_previous_question(user1.id, nil, true, question1.id)
                 .text).to eq('Q4?')
      end
      it 'finds previous question' do
        expect(Question
                 .next_or_previous_question(user1.id, nil, false, question1.id)
                 .text).to eq('Q3?')
      end
      it 'finds next answered by user1 question' do
        expect(Question
                 .next_or_previous_question(user1.id, true, true, question2.id)
                 .text).to eq('Q4?')
      end
      it 'finds previous answered by user1 question' do
        expect(Question
                 .next_or_previous_question(user1.id, true, false, question4.id)
                 .text).to eq('Q2?')
      end
      it 'finds next question without user1 answer' do
        expect(Question
                 .next_or_previous_question(user1.id, false, true, question1.id)
                 .text).to eq('Q3?')
      end
      it 'finds previous question without user1 answer' do
        expect(Question
                 .next_or_previous_question(user1.id, false, false, question3.id)
                 .text).to eq('Q1?')
      end
    end
  end
  describe 'scope_questions' do
    it 'returns all questions' do
      expect(Question.scope_questions('All questions', user1.id)
               .map{ |q| q.text }).to eq(['Q1?', 'Q2?','Q3?', 'Q4?'])
    end
    it 'returns all questions with answers' do
      expect(Question.scope_questions('Questions with answers', user1.id)
               .map{ |q| q.text }).to eq(['Q2?', 'Q4?'])
    end
    it 'returns all questions without answers' do
      expect(Question.scope_questions('Questions without answers', user1.id)
               .map{ |q| q.text }).to eq(['Q1?', 'Q3?'])
    end
  end
  describe 'define_question' do
    it 'finds next question' do
      expect(Question
        .define_question('All questions', user1.id, question1.id, true)
        .text).to eq('Q4?')
    end
    it 'finds previous question' do
      expect(Question
        .define_question('All questions', user1.id, question1.id, false)
        .text).to eq('Q3?')
    end
    it 'finds next answered by user1 question' do
      expect(Question
        .define_question('Questions with answers', user1.id, question1.id, true)
        .text).to eq('Q4?')
    end
    it 'finds previous answered by user1 question' do
      expect(Question
        .define_question('Questions with answers', user1.id, question1.id,
        false).text).to eq('Q2?')
    end
    it 'finds next question without user1 answer' do
      expect(Question
        .define_question('Questions without answers', user1.id, question1.id,
        true).text).to eq('Q3?')
    end
    it 'finds previous question without user1 answer' do
      expect(Question
        .define_question('Questions without answers', user1.id, question1.id,
        false).text).to eq('Q1?')
    end
  end
end
