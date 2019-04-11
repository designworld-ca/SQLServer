--verifies CIS Benchmark 5.3 logon audit level
--what level of logging of logon failures?
EXEC xp_loginconfig 'audit level';