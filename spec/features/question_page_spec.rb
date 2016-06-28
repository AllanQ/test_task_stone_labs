require 'rails_helper'

feature 'question page' do
  scenario 'questions exit' do
    let(:user) { create(:user) }
    let(:question_category) { create(:question) }
    let(:question_category_child) { create(:question,
                                           ancestry: question_category.id) }
    let(:question) { create(:question,
                            question_category_id: question_category_child.id) }
    let(:answer) { create(:answer, user: user,
                   question_id: question.id) }
    login_form.visit_page.login_as(user)
    visit('/')
    find('h3').click_link('Questions')
    click_link("#{question.text}")
    expect(page).to have_content("#{question_category.name}\
 -> #{question_category_child.name}")
    expect(page).to have_content(question.text)
    expect(page).to have_content(answer.text)
  end
end
