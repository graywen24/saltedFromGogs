test_fun_fail:
  salt.function:
  - name: test.retcode
  - tgt: ess-a1.cde.1nc
  - arg:
    - 666

