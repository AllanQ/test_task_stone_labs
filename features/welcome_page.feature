Feature: Welcome Page

  In order to see welcome message
  As a guest user
  I want to see welcome message

  Scenario: guest user sees welcome message
    Given I am a guest user
    When I go to the home page
    Then I should see welcome message
