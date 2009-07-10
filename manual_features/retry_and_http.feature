Feature: Retry responses and HTTP Errors
  As a user of AGCOD
  I want to properly handle retry responses and HTTP errors
  So that I can get certified

  Background:
    Given I have access to the AGCOD web service
    And I am logging transactions

  Scenario: #12 RESEND creation request
    Given I want to send request "9"
    When I send the request
    Then I should not receive a successful response

  Scenario: #13 RESEND cancel request
    Given I want to cancel request "2"
    When I send the request
    Then I should not receive a successful response

  Scenario: #14 HTTP error
    Given I want to send request "10"
    When I send the request
    Then I should not receive a successful response

  Scenario: #15 HTTP Void Error
    Given I want to void request "10"
    When I send the request
    Then I should not receive a successful response

  Scenario: #16 HTTP Cancel Error
    Given I want to cancel request "3"
    When I send the request
    Then I should not receive a successful response

  Scenario: #17 minimum amount
    Given I want to send request "11"
    When I send the request
    Then I should not receive a successful response



