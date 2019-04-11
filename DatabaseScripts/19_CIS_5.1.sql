--list error logs, CIS recommends at least 12 error logs files
--might return -1 depending on version

EXEC sys.sp_enumerrorlogs;
  


DECLARE @NumErrorLogs int;
EXEC master.sys.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'NumErrorLogs',
@NumErrorLogs OUTPUT;
SELECT ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles];

/* OR
if the script returns -1 take a screenshot from SQL Server Management Studio showing the number of error logs
Open up SQL Server Management Studio:
1.Expand the “Management” folder.
2.Right click on “SQL Server Logs”
3.Take a screenshot of the configuration
*/