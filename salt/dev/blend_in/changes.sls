
always-passes:
  test.succeed_without_changes:
    - name: foo
    - onchanges_in:
      - test: always-passes_two

always-passes_two:
  test.succeed_without_changes:
    - name: fooTwo
