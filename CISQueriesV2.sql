USE master;
GO

SELECT SERVERPROPERTY('ProductLevel') as SP_installed,
SERVERPROPERTY('ProductVersion') as Version,
SERVERPROPERTY('IsClustered') as Cluster,
SERVERPROPERTY('IsIntegratedSecurityOnly') as login_mode;
--------------------
SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name IN (
'Ad Hoc Distributed Queries',
'clr enabled',
'cross db ownership chaining',
'Database Mail XPs',
'default trace enabled',
'Ole Automation Procedures',
'remote access',
'remote admin connections',
'scan for startup procs',
'xp_cmdshell'
)
order by name;

-----------------------
SELECT name
FROM sys.databases
WHERE is_trustworthy_on = 1
AND name != 'msdb';

DECLARE @getValue INT;
EXEC master..xp_instance_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL
Server\MSSQLServer\SuperSocketNetLib',
@value_name = N'HideInstance',
@value = @getValue OUTPUT;
SELECT @getValue;


--is sa account disabled
SELECT name, is_disabled
FROM sys.server_principals
WHERE sid = 0x01;

--is sa account renamed
SELECT name
FROM sys.server_principals
WHERE sid = 0x01;
--and is there another account named sa
SELECT principal_id, name
FROM sys.server_principals
WHERE name = 'sa';


-- is autoclose set to 0
SELECT name, containment, containment_desc, is_auto_close_on
FROM sys.databases
WHERE containment <> 0 and is_auto_close_on = 1;

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
--check for orphan users
exec sp_MSforeachdb
'EXEC sp_change_users_login @Action=''Report'''

--find users that are using sql authentication
SELECT name as DBUser, authentication_type, type_desc
FROM sys.database_principals
WHERE name NOT IN ('dbo','Information_Schema','sys','guest')
AND type IN ('U','S','G')
GO

--are there extra permissions for the public server role
SELECT *
FROM master.sys.server_permissions
WHERE (grantee_principal_id = SUSER_SID(N'public') and state_desc LIKE
'GRANT%')
AND NOT (state_desc = 'GRANT' and [permission_name] = 'VIEW ANY DATABASE'
and class_desc = 'SERVER')
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and
class_desc = 'ENDPOINT' and major_id = 2)
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and
class_desc = 'ENDPOINT' and major_id = 3)
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and
class_desc = 'ENDPOINT' and major_id = 4)
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and
class_desc = 'ENDPOINT' and major_id = 5);

--built in group present?
SELECT pr.[name], pe.[permission_name], pe.[state_desc]
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name like 'BUILTIN%';

--local groups have login privileges?
USE [master]
GO
SELECT pr.[name] AS LocalGroupName, pe.[permission_name], pe.[state_desc],pr.[type_desc], pr.type
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.[principal_id] = pe.[grantee_principal_id]
WHERE pr.[type] NOT IN ('C','R', 'U');

--public role allowed to proxy?
USE [msdb]
GO
SELECT sp.name AS proxyname
FROM dbo.sysproxylogin spl
JOIN sys.database_principals dp
ON dp.sid = spl.sid
JOIN sysproxies sp
ON sp.proxy_id = spl.proxy_id
WHERE principal_id = USER_ID('public');
GO

--password expiration policies
SELECT l.[name], 'sysadmin membership' AS 'Access_Method',l.is_expiration_checked 
FROM sys.sql_logins AS l
where l.name not like '##%'
UNION ALL
SELECT l.[name], 'CONTROL SERVER' AS 'Access_Method',l.is_expiration_checked
FROM sys.sql_logins AS l
JOIN sys.server_permissions AS p
ON l.principal_id = p.grantee_principal_id
WHERE p.state IN ('G', 'W')
and l.name not like '##%';


--is complexity enforced
SELECT name, is_disabled, is_policy_checked
FROM sys.sql_logins
WHERE is_policy_checked = 0;

--list error logs
EXEC sys.sp_enumerrorlogs;
--at least 12 error logs files  -might return -1 depending on version
DECLARE @NumErrorLogs int;
EXEC master.sys.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'NumErrorLogs',
@NumErrorLogs OUTPUT;
SELECT ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles];

--what level of logging of logon failures?
EXEC xp_loginconfig 'audit level';

--where are failed logons stored?
SELECT
S.name AS 'Audit Name'
, CASE S.is_state_enabled
WHEN 1 THEN 'Y'
WHEN 0 THEN 'N' END AS 'Audit Enabled'
, S.type_desc AS 'Write Location'
, SA.name AS 'Audit Specification Name'
, CASE SA.is_state_enabled
WHEN 1 THEN 'Y'
WHEN 0 THEN 'N' END AS 'Audit Specification Enabled'
, SAD.audit_action_name
, SAD.audited_result
FROM sys.server_audit_specification_details AS SAD
JOIN sys.server_audit_specifications AS SA
ON SAD.server_specification_id = SA.server_specification_id
JOIN sys.server_audits AS S
ON SA.audit_guid = S.audit_guid
WHERE SAD.audit_action_id IN ('CNAU', 'LGFL', 'LGSD');


--is only safe access to assemblies allowed
SELECT name,
permission_set_desc
FROM sys.assemblies
where is_user_defined = 1;

--check encryption used
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.symmetric_keys
WHERE algorithm_desc NOT IN (''AES_128'',''AES_192'',''AES_256'')
AND db_id() > 4'
GO

--rsa 2048 encryption in use?
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.asymmetric_keys
WHERE key_length < 2048
AND db_id() > 4'
GO

