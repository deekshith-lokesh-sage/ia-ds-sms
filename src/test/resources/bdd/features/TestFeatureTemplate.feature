Feature: BDD Template

  Scenario: add fields with different types to payload
    Given init blank payload
    When set string field "a.b.c.d.e.newStrField":"newValue"
    And set string field "a.b.c.dimension.Field":"newValue"
    And set integer field "1.2.3.newIntField":101
    And set boolean field "true.false.newBooleanField":"true"
    And set number field "123.456.789.101112.newNumberField":12345.6789012
    Then verify request element "a.b.c.d.e.newStrField" contains "newValue"

  Scenario: load and update payload template
    Given load payload template "InputTemplate"
    And verify request element "description" contains "Change Me"
    When set string field "description":"New Description"
    Then verify request element "description" contains "New Description"

  Scenario: invoke contact api
    # will enhance this scenario to first post a contact once resolve
    #   1. audit trail issue
    #   2. the contact add issue: "object contact cannot be created because of validation errors\nA value is required for the field id of object contact\n"
    When get a single "contact" object with key 1
    Then verify response element "status" contains "active"


