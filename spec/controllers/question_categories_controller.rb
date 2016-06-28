require 'rails_helper'

describe QuestionCategoriesController do

  let(:question_category) { create(:question_category) }

  shared_examples 'does not delete' do
    it 'does not delete question from database' do
      delete :destroy, id: question_category
      expect(QuestionCategory.exists?(question.id)).to be_truthy
    end
  end

  describe 'not authenticated user' do
    describe 'DELETE destroy' do
      it 'redirects to login page' do
        delete :destroy, id: question_category
        expect(response).to redirect_to(new_user_session_url)
      end
      it_behaves_like 'does not delete'
    end
  end

  describe 'authenticated user' do

    shared_examples 'redirect to questions page' do
      it 'redirects to questions#index' do
        delete :destroy, id: question_category
        expect(response).to redirect_to(questions_path)
      end
    end

    describe 'not activated user' do
      let(:user) { create(:user, activated: false) }
      before do
        sign_in(user)
      end
      describe 'DELETE destroy' do
        it 'redirects to welcome page' do
          delete :destroy, id: question_category
          expect(response).to redirect_to(root_path)
        end
        it_behaves_like 'does not delete'
      end
    end

    describe 'activated user' do
      let(:user) { create(:user) }
      before do
        sign_in(user)
      end
      describe 'DELETE destroy' do
        it_behaves_like 'redirect to questions page'
        it_behaves_like 'does not delete'
      end
    end

    describe 'admin' do
      let(:user) { create(:user, admin: true) }
      before do
        sign_in(user)
      end
      describe 'DELETE destroy' do
        it_behaves_like 'redirect to questions page'
        it 'deletes question from database' do
          delete :destroy, id: question_category
          expect(QuestionCategory.exists?(question_category.id)).to be_falsey
        end
      end
    end
  end
end
