Feature: Insufficient Funds
  As a user of the agcod service
  I want to handle when I have insufficient funds appropriately
  So I can get certified

  Background:
    Given I have access to the AGCOD web service
    And I am logging transactions
    
  Scenario: Insufficient Funds
    Given I want to send request "6"
    And I send the request
    Then I should not receive a successful response
