require 'rails_helper'

describe AnswersController do

  describe 'not authenticated user' do
    describe 'POST create' do
      let(:answer) { attributes_for(:answer) }
      it 'redirects to login page' do
        post :create, answer: answer
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'do not create new answer in database' do
        expect {
          post :create, answer: answer
        }.not_to change(Answer, :count)
      end
    end
    describe 'PUT update' do
      let(:answer) { create(:answer, text: 'Original answer') }
      it 'redirects to questions#index' do
        put :update, id: answer, text: 'New Answer'
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'does not updates answer in database' do
        put :update, id: answer, text: 'New Answer'
        answer.reload
        expect(answer.text).to eq('Original answer')
      end
    end
    describe 'DELETE destroy' do
      let(:answer) { create(:answer) }
      it 'redirects to login page' do
        delete :destroy, id: answer
        expect(response).to redirect_to(new_user_session_url)
      end
      it 'does not delete question from database' do
        delete :destroy, id: answer
        expect(Answer.exists?(question.id)).to be_truthy
      end
    end
  end

  describe 'authenticated user' do

    shared_examples 'full access to answer' do
      describe 'POST create' do
        let(:question) { create(:question) }
        let(:answer) { attributes_for(:answer, question: question) }
        it 'redirects to questions#show' do
          post :create, answer: answer
          expect(response).to redirect_to(question_path(assigns[:question]))
        end
        it 'create new answer in database' do
          expect {
            post :create, answer: answer
          }.to change(Answer, :count).by(1)
        end
      end
      describe 'PUT update' do
        let(:question) { create(:question) }
        let(:answer) { create(:answer, user: user, question: question) }
        it 'redirects to questions#show' do
          put :update, id: answer, text: 'New Answer'
          expect(response).to redirect_to(question_path(assigns[:question]))
        end
        it 'updates answer in database' do
          put :update, id: answer, text: 'New Answer'
          answer.reload
          expect(answer.text).to eq('New Answer')
        end
      end
      describe 'DELETE destroy' do
        let(:answer) { create(:answer) }
        it 'redirect to question#show' do
          question_id = answer.question_id
          delete :destroy, id: answer
          expect(response).to redirect_to(question_path question_id)
        end
        it 'deletes answer from database' do
          delete :destroy, id: answer
          expect(Answer.exists?(answer.id)).to be_falsy
        end
      end
    end

    describe 'not activated user' do
      let(:user) { create(:user, activated: false) }
      before do
        sign_in(user)
      end
      describe 'POST create' do
        answer = attributes_for(:answer, user: user)
        it 'redirects to welcome page' do
          post :create, answer: answer
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'PUT update' do
        answer = create(:answer, user: user)
        it 'redirects to welcome page' do
          put :update, id: answer
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'DELETE destroy' do
        answer = create(:answer, user: user)
        it 'redirects to welcome page' do
          delete :destroy, id: answer
          expect(response).to redirect_to(root_path)
        end
      end
    end

    describe 'activated user' do
      context 'is not the owner of the answer' do
        let(:user_owner) { create(:user) }
        let(:user_is_not_owner) { create(:user) }
        before do
          sign_in(user_is_not_owner)
        end
        describe 'POST create' do
          let(:answer) { attributes_for(:answer, user: user_owner) }
          it 'redirects to questions#index' do
            post :create, answer: answer
            expect(response).to redirect_to(questions_path)
          end
          it 'do not create new answer in database' do
            expect {
              post :create, answer: answer
            }.not_to change(Answer, :count)
          end
        end
        describe 'PUT update' do
          let(:answer) { create(:answer, user: user_owner,
                                        text: 'Original answer') }
          it 'redirects to questions#index' do
            put :update, id: answer, text: 'New Answer'
            expect(response).to redirect_to(questions_path)
          end
          it 'does not updates answer in database' do
            put :update, id: answer, text: 'New Answer'
            answer.reload
            expect(answer.text).to eq('Original answer')
          end
        end
        describe 'DELETE destroy' do
          let(:answer) { create(:answer, user: user_owner) }
          it 'redirects to questions#index' do
            delete :destroy, id: answer
            expect(response).to redirect_to(questions_path)
          end
          it 'does not delete answer from database' do
            delete :destroy, id: answer
            expect(Answer.exist?(answer.id)).to be_truthy
          end
        end
      end

      context 'is the owner of the answer' do
        let(:user) { create(:user) }
        before do
          sign_in(user)
        end
        it_behaves_like 'full access to answer'
      end
    end

    describe 'admin' do
      let(:user) { create(:user, admin: true) }
      before do
        sign_in(user)
      end
      it_behaves_like 'full access to answer'
    end
  end
end
