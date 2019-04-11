--verifies CIS benchmark 6.2 only safe CLR assemblies allowed
--is only safe access to assemblies allowed
SELECT name,
permission_set_desc
FROM sys.assemblies
where is_user_defined = 1;