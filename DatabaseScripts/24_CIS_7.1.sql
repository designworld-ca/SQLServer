--check encryption used
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.symmetric_keys
WHERE algorithm_desc NOT IN (''AES_128'',''AES_192'',''AES_256'')
AND db_id() > 4'
GO

--shows what encryption options are in use for connections between the server and client
--requires sysadmin privilege
SELECT distinct encrypt_option 
FROM sys.dm_exec_connections 