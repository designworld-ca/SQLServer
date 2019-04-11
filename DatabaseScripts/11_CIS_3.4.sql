--verifies CIS Benchmark 3.4
--find users that are using sql authentication

SELECT name as DBUser, authentication_type, type_desc
FROM sys.database_principals
WHERE name NOT IN ('dbo','Information_Schema','sys','guest')
AND type IN ('U','S','G')
GO
