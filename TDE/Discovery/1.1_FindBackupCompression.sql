--https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/backup-compression-sql-server?view=sql-server-ver15
--For example, a 3:1 compression ratio indicates that you are saving about 66% on disk space.
SELECT b.database_name, 
b.backup_start_date, 
b.backup_finish_date, 
CAST(DATEDIFF(minute,b.backup_start_date, b.backup_finish_date)AS DECIMAL (5,2)) AS DURATION_MINUTES,
CAST(b.backup_size/compressed_backup_size AS DECIMAL (5,2)) AS compression_ratio,
CAST( ((b.backup_size - b.compressed_backup_size)/1024/1024) AS DECIMAL (15,2)) AS EXTRA_SPACE_REQD_MB
FROM msdb..backupset b
WHERE b.backup_finish_date = (SELECT MAX(c.backup_finish_date)
FROM msdb..backupset c
WHERE c.database_name = b.database_name)
Order by 1,2 desc;  


--Part 2
--shows an approximate idea of how many extra GB will be required for the instance
SELECT SUM(
CAST( ((b.backup_size - b.compressed_backup_size)/1024/1024/1024) AS DECIMAL (15,2))) AS TOTAL_EXTRA_SPACE_REQD_GB
FROM msdb..backupset b
WHERE b.backup_finish_date = (SELECT MAX(c.backup_finish_date)
FROM msdb..backupset c
WHERE c.database_name = b.database_name)