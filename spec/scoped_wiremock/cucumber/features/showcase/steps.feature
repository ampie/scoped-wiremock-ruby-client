Feature: Login
  @ampie
  Scenario: Successfully login in
    Given I see an empty login form
    When I enter details
    Then I see the success message