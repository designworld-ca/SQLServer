--checks for CIS Control
--5.1 Minimize and Sparingly Use Administrative Privileges

select * from sys.syslogins
go
select * from sys.sql_logins 
go
sp_helprolemember 'db_securityadmin'
go
sp_helprolemember 'db_owner'
go
sp_helprolemember 'db_accessadmin'
go
sp_helpsrvrolemember 'sysadmin'
go
sp_helpsrvrolemember 'serveradmin'
go
sp_helpsrvrolemember 'securityadmin'
go
EXEC sp_helprotect 'application rolename'
go
