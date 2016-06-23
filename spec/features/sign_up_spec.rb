require 'rails_helper'
require_relative '../support/new_user_form'

feature 'Sign up' do
  let(:new_user_form) { NewUserForm.new}
  xscenario 'with valid data' do
    new_user_form.visit_page.fill_in_with(
      name: 'Test Name',
      email: 'testemail@test.com',
      password: 'testpassword',
      password_confirmation: 'testpassword'
    ).submit
    expect(page).to have_content('Welcome! You have signed up successfully.')
    expect(User.last.name).to eq('Test Name')
  end

  xcontext 'without' do
    scenario 'name' do
      new_user_form.visit_page.fill_in_with(
        email: 'testemail@test.com',
        password: 'testpassword',
        password_confirmation: 'testpassword'
      ).submit
      expect(page).to have_content("Name can't be blank")
    end
    scenario 'email' do
      new_user_form.visit_page.fill_in_with(
        name: 'Test Name',
        password: 'testpassword',
        password_confirmation: 'testpassword'
      ).submit
      expect(page).to have_content("Email can't be blank")
    end
    scenario 'password' do
      new_user_form.visit_page.fill_in_with(
        name: 'Test Name',
        email: 'testemail@test.com',
        password_confirmation: 'testpassword'
      ).submit
      expect(page).to have_content("Password can't be blank")
    end
    scenario 'password confirmation' do
      new_user_form.visit_page.fill_in_with(
        name: 'Test Name',
        email: 'testemail@test.com',
        password: 'testpassword'
      ).submit
      expect(page)
        .to have_content("Password confirmation doesn't match Password")
    end
  end

  scenario 'with too short password' do
    new_user_form.visit_page.fill_in_with(
      name: 'Test Name',
      email: 'testemail@test.com',
      # HACK : @minimum_password_length is nil
      password: "#{'a' * (8 - 1)}",
      password_confirmation: "#{'a' * (8 - 1)}"
    ).submit
    expect(page).to have_content('Password is too short')
  end

  scenario 'with wrong password confirmation' do
    new_user_form.visit_page.fill_in_with(
      name: 'Test Name',
      email: 'testemail@test.com',
      password: 'testpassword',
      password_confirmation: 'passwordtest'
    ).submit
    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
