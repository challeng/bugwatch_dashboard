Feature: When Bugwatch receives activity from Pivotal Tracker
Then we want to keep track of stories related to bugs

  Background:
    Given I have a repository "bugwatch" with a pivotal project id "50"

  Scenario: Story created
    When I receive pivotal tracker activity:
      | id | project_id | event_type   | story_type | current state |
      | 1  | 50         | story_create | bug        | unscheduled   |
    Then the pivotal tracker open defects for "bugwatch" should be:
      | id |
      | 1  |

  Scenario: Story updated to started
    Given I have a pivotal tracker defect:
      | title       | status | id  |
      | Doesnt work | open   | 123 |
    When I receive pivotal tracker activity:
      | id  | project_id | event_type   | story_type | current state |
      | 123 | 50         | story_update | bug        | started       |
    Then the pivotal tracker open defects for "bugwatch" should be:
      | id  |
      | 123 |

  Scenario: Story updated to finished
    Given I have a pivotal tracker defect:
      | title       | status | id  |
      | Doesnt work | open   | 123 |
    When I receive pivotal tracker activity:
      | id  | project_id | event_type   | story_type | current_state |
      | 123 | 50         | story_update | bug        | finished      |
    Then the pivotal tracker open defects for "bugwatch" should be:
      | id |

  Scenario: Story deleted when started
    Given I have a pivotal tracker defect:
      | title    | status | id  |
      | Some bug | open   | 999 |
    When I receive pivotal tracker activity:
      | id  | project_id | event_type   | story_type | current_state |
      | 999 | 50         | story_delete | bug        | deleted       |
    Then the pivotal tracker open defects for "bugwatch" should be:
      | id |
