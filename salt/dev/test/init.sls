
test_another_name:
  test.succeed_without_changes:
    - name: foo

test_the_same_name:
  test.fail_without_changes:
    - name: bar

this_will_fail:
  test.fail_without_changes:
  - onchanges:
    - test: test

this_wont_fail:
  test.succeed_without_changes:
  - onfail:
    - test: test

