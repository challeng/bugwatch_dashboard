Feature: When Bugwatch receives activity from Pivotal Tracker
  Then we want to keep track of stories related to bugs

  Scenario: Story created
    Given I have a repository "bugwatch" with a pivotal project id "50"
    When I receive pivotal tracker activity:
      | id | project_id | event_type   | description | story_type |
      | 1  | 50         | story_create | New bug     | bug        |
    Then the pivotal tracker defects for "bugwatch" should be:
      | id |
      | 1  |