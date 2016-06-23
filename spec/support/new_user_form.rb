class NewUserForm
  include Capybara::DSL

  def visit_page
    visit('/')
    find('h3').click_link('SIGN UP')
    self
  end

  def fill_in_with(params = {})
    find('#sign-up').fill_in('user_name',
                             with: params.fetch(:name, 'Test Name'))
    find('#sign-up').fill_in('user_email',
                             with: params.fetch(:email, 'testemail@test.com'))
    find('#sign-up').fill_in('user_password',
                             with: params.fetch(:password, 'testpassword'))
    find('#sign-up').fill_in('user_password_confirmation',
                             with: params
                               .fetch(:password_confirmation, 'testpassword'))
    self
  end

  def submit
    find('.actions').click_button('SIGN UP')
    self
  end
end