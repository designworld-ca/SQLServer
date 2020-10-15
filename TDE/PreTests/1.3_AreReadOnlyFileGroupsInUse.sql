--cannot implement TDE if any read only file groups are in use (such as for ETL)

SELECT name, is_read_only 
FROM sys.filegroups
