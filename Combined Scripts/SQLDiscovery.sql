--before running this script go to Options/Query Results/SQL Server/Results to text
--and set output format as comma delimited
--then in the gui set the output to text
--select all results and copy into one text file per server

USE master;
GO
SELECT SYSTEM_USER AS 'SYSTEM USER', CURRENT_TIMESTAMP AS Date_Script_Run;
SELECT @@SERVERNAME AS Server_name;
SELECT SERVERPROPERTY('ProductLevel') as SP_installed,
SERVERPROPERTY('ProductVersion') as Version,
SERVERPROPERTY('IsClustered') as Cluster,
SERVERPROPERTY('IsIntegratedSecurityOnly') as login_mode;
--------------------
SELECT name AS Configuration_Name,
CAST(value as int) as Value_configured,
CAST(value_in_use as int) as Value_in_use
FROM sys.configurations
WHERE name IN (
'Ad Hoc Distributed Queries',
'clr enabled',
'clr strict security', --for newer SQL Server versions
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
SELECT name AS Is_trustworthy_mode_on
FROM sys.databases
WHERE is_trustworthy_on = 1
AND name != 'msdb';

--CIS 2.12 is instance hidden, may return file not found or NULL
DECLARE @getValue INT;
EXEC master..xp_instance_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL
Server\MSSQLServer\SuperSocketNetLib',
@value_name = N'HideInstance',
@value = @getValue OUTPUT;
SELECT @getValue AS Is_Hide_Instance_On;


--is sa account disabled
SELECT name, is_disabled as Is_SA_Account_Disabled
FROM sys.server_principals
WHERE sid = 0x01;

--is sa account renamed
SELECT name AS Current_SA_Name
FROM sys.server_principals
WHERE sid = 0x01;

--and is there another account named sa
SELECT principal_id, name AS Is_There_Another_Account_Named_SA
FROM sys.server_principals
WHERE name = 'sa';


-- is autoclose set to 0
SELECT name AS Databases_Set_To_Autoclose, containment, containment_desc, is_auto_close_on
FROM sys.databases
WHERE containment <> 0 and is_auto_close_on = 1;

--verify guest account has no connect privileges
SELECT 'Databases where guest account has privileges'
exec sp_MSforeachdb
'SELECT DB_NAME() AS DatabaseName, ''guest'' AS Database_User,
[permission_name], [state_desc]
FROM sys.database_permissions
WHERE [grantee_principal_id] = DATABASE_PRINCIPAL_ID(''guest'')
AND [state_desc] LIKE ''GRANT%''
AND [permission_name] = ''CONNECT''
AND DB_NAME() NOT IN (''master'',''tempdb'',''msdb'')'
GO

SELECT 'Check for orphan users';
exec sp_MSforeachdb
'EXEC sp_change_users_login @Action=''Report'''

--find users that are using sql authentication
SELECT name as 'DBUser using SQL Authentication', authentication_type, type_desc
FROM sys.database_principals
WHERE name NOT IN ('dbo','Information_Schema','sys','guest')
AND type IN ('U','S','G')
AND authentication_type = 2;
GO

SELECT 'Are there extra permissions for the public server role';
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
SELECT pr.[name] AS 'Is Builtin Group present', pe.[permission_name], pe.[state_desc]
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name like 'BUILTIN%';

--local groups have login privileges?
USE [master]
GO
SELECT pr.[name] AS 'Local Group Name with Login Privileges', pe.[permission_name], pe.[state_desc],pr.[type_desc], pr.type
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.[principal_id] = pe.[grantee_principal_id]
WHERE pr.[type] NOT IN ('C','R', 'U');

--public role allowed to proxy?
USE [msdb]
GO
SELECT sp.name AS 'Public role with proxy'
FROM dbo.sysproxylogin spl
JOIN sys.database_principals dp
ON dp.sid = spl.sid
JOIN sysproxies sp
ON sp.proxy_id = spl.proxy_id
WHERE principal_id = USER_ID('public');
GO

SELECT 'CIS 4.2 password expiration policies';
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


SELECT 'Is complexity enforced';
SELECT name As 'Is password complexity enabled', is_disabled, is_policy_checked
FROM sys.sql_logins
WHERE is_policy_checked = 0;

SELECT 'Show number of error logs'
EXEC sys.sp_enumerrorlogs;
--at least 12 error logs files  -might return -1 depending on version
DECLARE @NumErrorLogs int;
EXEC master.sys.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'NumErrorLogs',
@NumErrorLogs OUTPUT;
SELECT ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles];

SELECT 'Verify level of logging for logon failures'
EXEC xp_loginconfig 'audit level';

SELECT 'CIS 5.4 are successful and failed logons audited?';
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

SELECT '5.3 Ensure login auditing is set to failed logins';
exec xp_loginconfig 'audit level';

--is only safe access to assemblies allowed
SELECT name AS 'Assemblies that can be accessed',
permission_set_desc
FROM sys.assemblies
where is_user_defined = 1;

SELECT 'Show if weak or no encryption used';
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.symmetric_keys
WHERE algorithm_desc NOT IN (''AES_128'',''AES_192'',''AES_256'')
AND db_id() > 4'
GO

SELECT 'Is any encryption less than rsa 2048 in use?';
exec sp_MSforeachdb
'SELECT db_name() AS Database_Name, name AS Key_Name
FROM sys.asymmetric_keys
WHERE key_length < 2048
AND db_id() > 4'
GO

--See CIS 16 Account Monitoring and Control
--show the sysadmins
USE master
GO

SELECT  p.name AS [Loginname_With_Sysadmin] ,
        CASE
        WHEN p.is_disabled = 1
        THEN 'LOCKED'
        ELSE 'OPEN'
        END as 'Account Status'
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
        AND s.sysadmin = 1
GO

SELECT 'CIS 3.10 can windows local groups login in to SQL Server';
USE [master]
GO
SELECT pr.[name] AS LocalGroupName, pe.[permission_name], pe.[state_desc]
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.[principal_id] = pe.[grantee_principal_id]
WHERE pr.[type_desc] = 'WINDOWS_GROUP'
AND pr.[name] like CAST(SERVERPROPERTY('MachineName') AS nvarchar) + '%';

SELECT 'List linked servers';
SELECT s.name, s.product, s.provider, s.data_source, s.modify_date
FROM sys.servers s
WHERE is_linked = 1;