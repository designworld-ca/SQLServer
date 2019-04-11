--CIS Benchmark 3.10
--local groups have login privileges?
--should not return any rows
USE [master]
GO
SELECT pr.[name] AS LocalGroupName, pe.[permission_name], pe.[state_desc],pr.[type_desc], pr.type
FROM sys.server_principals pr
JOIN sys.server_permissions pe
ON pr.[principal_id] = pe.[grantee_principal_id]
WHERE pr.[type] NOT IN ('C','R', 'U');
