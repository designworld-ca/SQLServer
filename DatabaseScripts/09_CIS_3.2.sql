--Verifies CIS Benchmark 3.2

--verify guest account has no connect privileges
exec sp_MSforeachdb
'SELECT DB_NAME() AS DatabaseName, ''guest'' AS Database_User,
[permission_name], [state_desc]
FROM sys.database_permissions
WHERE [grantee_principal_id] = DATABASE_PRINCIPAL_ID(''guest'')
AND [state_desc] LIKE ''GRANT%''
AND [permission_name] = ''CONNECT''
AND DB_NAME() NOT IN (''master'',''tempdb'',''msdb'')'
GO

