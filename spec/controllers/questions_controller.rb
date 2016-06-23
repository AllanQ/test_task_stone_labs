require 'rails_helper'

describe QuestionsController do

  describe 'not authenticated user' do
    describe 'GET index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    describe 'GET show' do
      it 'redirects to login page' do
        get :show
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    describe 'DELETE destroy' do
      let(:question) { create(:question) }
      it 'redirects to login page' do
        delete :destroy, id: question
        expect(response).to redirect_to(new_user_session_url)
      end
      it 'does not delete question from database' do
        delete :destroy, id: question
        expect(Question.exists?(question.id)).to be_truthy
      end
    end
  end

  describe 'authenticated user' do

    shared_examples 'access to questions' do
      describe 'GET index' do
        it 'renders :index template' do
          get :index
          expect(response).to render_template(:index)
        end
      end
      describe 'GET show' do
        let(:question) { create(:question) }
        let(:answer) { create(:answer, user_id: user.id,
                              question_id: question.id) }
        it 'renders :show template' do
          get :show, id: question  #.id
          expect(response).to render_template(:show)
        end
        it 'assigns requested question to @question' do
          get :show, id: question  #.id
          expect(assigns(:question)).to eq(question)
        end
        it 'assigns requested answer to @answer' do
          get :show, id: question  #.id
          expect(assigns(:answer)).to eq(answer)
        end
      end
    end

    describe 'not activated user' do
      let(:user) { create(:user, activated: false) }
      before do
        sign_in(user)
      end
      describe 'GET index' do
        it 'redirects to welcome page' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'GET show' do
        it 'redirects to welcome page' do
          question = create(:question)
          get :show, id: question
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'DELETE destroy' do
        let(:question) { create(:question) }
        it 'redirects to welcome page' do
          delete :destroy, id: question
          expect(response).to redirect_to(root_path)
        end
        it 'does not delete question from database' do
          delete :destroy, id: question
          expect(Question.exists?(question.id)).to be_truthy
        end
      end
    end

    describe 'activated user' do
      let(:user) { create(:user) }
      before do
        sign_in(user)
      end
      it_behaves_like 'access to questions'
      describe 'DELETE destroy' do
        let(:question) { create(:question) }
        it 'redirects to questions#index' do
          delete :destroy, id: question
          expect(response).to redirect_to(questions_path)
        end
        it 'does not delete question from database' do
          delete :destroy, id: question
          expect(Question.exists?(question.id)).to be_truthy
        end
      end
    end

    describe 'admin' do
      let(:user) { create(:user, admin: true) }
      before do
        sign_in(user)
      end
      it_behaves_like 'access to questions'
      describe 'DELETE destroy' do
        let(:question) { create(:question) }
        it 'redirect to questions#index' do
          delete :destroy, id: question
          expect(response).to redirect_to(questions_path)
        end
        it 'deletes question from database' do
          delete :destroy, id: question
          expect(Question.exists?(question.id)).to be_falsy
        end
      end
    end
  end
end
