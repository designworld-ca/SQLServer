
--refers to CIS benchmarks 2.13-2.14-2.17

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