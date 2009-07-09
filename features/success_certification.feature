Feature: Successful Cases for Certification 
  As a user of the AGCOD api
  I want to run certification tests that create successful responses
  So that I can be authorized for production access
 
  Background:
    Given I have access to the AGCOD web service
    And I am logging transactions

  Scenario: #1 Successful Health Check
    Given I want to send a health check request
    When I send the request
    Then I should receive a successful response
  
  Scenario: #2a Successful Creation of a Gift Card for $12
    Given I want to create a gift card in the amount of $12
    When I send the request
    Then I should receive a successful response
    And I should get a claim code

  Scenario: #2b Successful Creation of a Gift Card for $999
    Given I want to create a gift card in the amount of $999
    When I send the request
    Then I should receive a successful response
    And I should get a claim code

  Scenario: #3 Sending the same Gift Card Request ID
    Given I've sent a gift card request in the amount of $100
    And the request was successful
    And I want to create a gift card with the same request id
    When I send the request
    Then I should not receive a successful response

  Scenario: #4 Cancel a Gift Card Successfully
    Given I've sent a gift card request in the amount of $50.02
    And the request was successful
    And I want to cancel the gift card requested
    When I send the request
    Then I should receive a successful response

  Scenario: #5 Void a Gift Card Successfully
    Given I've sent a gift card request in the amount of $999.99
    And the request was successful
    And I want to void the gift card requested
    When I send the request
    Then I should receive a successful response

