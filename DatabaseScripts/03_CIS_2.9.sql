--CIS Benchmark 2.9
--no rows should be returned
SELECT name
FROM sys.databases
WHERE is_trustworthy_on = 1
AND name != 'msdb';