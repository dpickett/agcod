Feature: Cancel claimed Gift Card Error Handling
  As a user of the agcod service
  I want to handle when I attempt to cancel a claimed gift card
  So I can get certified

  Background:
    Given I have access to the AGCOD web service
    And I am logging transactions
    
  Scenario: Claimed Gift Card
    Given I want to cancel request "1"
    When I send the request
    Then I should not receive a successful response
