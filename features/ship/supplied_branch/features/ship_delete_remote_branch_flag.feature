Feature: skip deleting the remote branch when shipping another branch

  Background:
    Given the feature branches "feature" and "other"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE        |
      | feature | local, origin | feature commit |
      | other   | local         | other commit   |
    And the current branch is "other"
    And setting "ship-delete-remote-branch" is "false"
    When I run "git-town ship feature -m 'feature done'"
    And origin deletes the "feature" branch

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                            |
      | other   | git fetch --prune --tags           |
      |         | git checkout main                  |
      | main    | git rebase origin/main             |
      |         | git checkout feature               |
      | feature | git merge --no-edit origin/feature |
      |         | git merge --no-edit main           |
      |         | git checkout main                  |
      | main    | git merge --squash feature         |
      |         | git commit -m "feature done"       |
      |         | git push                           |
      |         | git branch -D feature              |
      |         | git checkout other                 |
    And the current branch is now "other"
    And the branches are now
      | REPOSITORY    | BRANCHES    |
      | local, origin | main, other |
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE      |
      | main   | local, origin | feature done |
      | other  | local         | other commit |
    And this branch lineage exists now
      | BRANCH | PARENT |
      | other  | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                       |
      | other   | git checkout main                             |
      | main    | git branch feature {{ sha 'feature commit' }} |
      |         | git revert {{ sha 'feature done' }}           |
      |         | git push                                      |
      |         | git checkout feature                          |
      | feature | git checkout main                             |
      | main    | git checkout other                            |
    And the current branch is now "other"
    And now these commits exist
      | BRANCH  | LOCATION      | MESSAGE               |
      | main    | local, origin | feature done          |
      |         |               | Revert "feature done" |
      | feature | local         | feature commit        |
      | other   | local         | other commit          |
    And the branches are now
      | REPOSITORY | BRANCHES             |
      | local      | main, feature, other |
      | origin     | main, other          |
    And the initial branch hierarchy exists
