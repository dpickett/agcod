Feature: Error Handling
  As a user of the agcod service
  I want to correctly handle errors
  So I can get certified

  Background:
    Given I have access to the AGCOD web service
    And I am logging transactions

  Scenario: #8 Error Handling E203
    Given I specify response_id "AAAEPY26ZX1BSY"
    And I want to cancel request "2"
    When I send the request
    Then I should not receive a successful response

  Scenario: #9 Error Handling E204
    Given I specify response_id "A3REPY26ZX1BSY"
    And I want to cancel request "2"
    When I send the request
    Then I should not receive a successful response

  Scenario: #10 Error Handling for no currency code
    Given I specify the currency of "" 
    And I want to send request "7"
    When I send the request
    Then I should not receive a successful response

  Scenario: #11 Error Handling with Max Limit
    Given I want to send request "8"
    When I send the request
    Then I should not receive a successful response
