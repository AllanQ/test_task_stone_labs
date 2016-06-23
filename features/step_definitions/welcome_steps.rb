Given(/^I am a guest user$/) do
end

When(/^I go to the home page$/) do
  visit('/')
end

Then(/^I should see welcome message$/) do
  expect(page).to have_content('Hello')
end
