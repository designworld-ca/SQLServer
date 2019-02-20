USE master
GO
 
SELECT  p.name AS [loginname] ,
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
