--Verifies CIS Benchmark 2.12 Ensure 'Hide Instance' option is set to 'Yes' 
--for Production SQL
--A value of 1 should be returned to be compliant.

DECLARE @getValue INT;
EXEC master..xp_instance_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL
Server\MSSQLServer\SuperSocketNetLib',
@value_name = N'HideInstance',
@value = @getValue OUTPUT;
SELECT @getValue;
