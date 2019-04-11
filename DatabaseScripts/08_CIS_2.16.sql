--verifies CIS Benchmark 2.16
-- is autoclose set to 0

SELECT name, containment, containment_desc, is_auto_close_on
FROM sys.databases
WHERE containment <> 0 and is_auto_close_on = 1 
order by name;
