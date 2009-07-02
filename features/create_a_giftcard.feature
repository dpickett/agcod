Feature: As a user of the AGCOD web service
I want create a gift card
So that I can remit payment to a third party

  Scenario: Pay someone $35 successfully
    Given I have access to the AGCOD web service
    And I want to create a gift card in the amount of $35.00
    When I send the request
    Then it should be successful
    And I should get a response id
    And I should get a claim code
