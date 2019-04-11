--verify unnecessary sql server protocols are disabled
--specifically anything other than tcp/ip
--check to see if any named pipes connections are in use when this query is run
--this protocol allows remote procedure calls and should not be in use unless critical to an application
SELECT distinct net_transport 
FROM sys.dm_exec_connections 
