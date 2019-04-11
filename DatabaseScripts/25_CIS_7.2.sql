--verifies CIS Benchmark 7.2
--rsa 2048 encryption in use?
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.asymmetric_keys
WHERE key_length < 2048
AND db_id() > 4'
GO