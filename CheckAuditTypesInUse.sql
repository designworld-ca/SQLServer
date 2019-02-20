--see if any audits have been created
select * from sys.database_audit_specifications;
--see details on any audits
select * from sys.server_audits;
--see if any file based audits
select * from sys.server_file_audits;

--see if common criteria compliance is enabled
GO
sp_configure 'show advanced options', 1;  
GO
RECONFIGURE;
GO
--this option enforces login auditing, overwrite memory before reallocating
--and table DENY takes precedence over a column grant
--also needs a script to be run to finish configuration of this
sp_configure 'common criteria compliance enabled'  
GO 
--C2 has been deprecated but may be in use in older versions
sp_configure 'c2 audit mode'
GO
sp_configure 'show advanced options', 0;  
GO
RECONFIGURE;

--see if extended events are in use which can be used to audit events
select * from sys.dm_xe_sessions
