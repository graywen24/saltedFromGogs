test_fun_success:
  salt.function:
  - name: test.retcode
  - tgt: ess-a1.cde.1nc
  - arg:
    - 0
