require 'rails_helper'

feature 'questions page' do
  let(:user) { create(:user) }
  scenario 'questions do not exit' do
    login_form.visit_page.login_as(user)
    visit('/')
    find('h3').click_link('Questions')
    expect(page).to have_content('All questions')
    expect(page).to have_content('There are not any questions yet')
  end
  scenario 'questions exit' do
    let(:question) { create(:question) }
    login_form.visit_page.login_as(user)
    visit('/')
    find('h3').click_link('Questions')
    expect(page).to have_content('All questions')
    expect(page).to have_content('Questions with answers')
    expect(page).to have_content('Questions without answers')
    expect(page).to have_content(question.text)
  end
end
