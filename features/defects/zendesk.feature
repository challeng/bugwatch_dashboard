Feature: When Bugwatch receives ticket activity from Zendesk
Then we want to track the tickets related to defects

  Background:
    Given I have a repository "bugwatch"
    And the repository "bugwatch" has a zendesk identifier "bugwatch"

  Scenario: Ticket created with new status
    When I receive zendesk activity:
      | id  | priority | title  | status | secret   |
      | 123 | urgent   | Broken | New    | bugwatch |
    Then I should have the following open zendesk defects:
      | id  |
      | 123 |

  Scenario: Ticket created with open status
    When I receive zendesk activity:
      | id  | priority | title  | status | secret   |
      | 123 | urgent   | Broken | Open   | bugwatch |
    Then I should have the following open zendesk defects:
      | id  |
      | 123 |

  Scenario: Ticket created with pending status
    When I receive zendesk activity:
      | id  | priority | title  | status  | secret   |
      | 123 | urgent   | Broken | Pending | bugwatch |
    Then I should have the following open zendesk defects:
      | id  |
      | 123 |

  Scenario: Ticket created with solved status
    When I receive zendesk activity:
      | id  | priority | title  | status | secret   |
      | 123 | urgent   | Broken | Solved | bugwatch |
    Then I should have the following open zendesk defects:
      | id |