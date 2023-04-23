--TDE does not allow instant file initialization, so it takes a little longer to add more space to a database file.  
--This should not be an issue except for edge cases where the database frequently loads lots of data fast
--such as a data warehouse or analytics use case

select DB_NAME(mf.database_id) database_name
, mf.name logical_name
, CONVERT (DECIMAL (20,2) , (CONVERT(DECIMAL, size)/128)) [file_size_MB]
, CASE mf.is_percent_growth
WHEN 1 THEN 'Yes'
ELSE 'No'
END AS [is_percent_growth]
, CASE mf.is_percent_growth
WHEN 1 THEN CONVERT(VARCHAR, mf.growth) + '%'
WHEN 0 THEN CONVERT(VARCHAR, mf.growth/128) + ' MB'
END AS [growth_in_increment_of]
, CASE mf.is_percent_growth
WHEN 1 THEN
CONVERT(DECIMAL(20,2), (((CONVERT(DECIMAL, size)*growth)/100)*8)/1024)
WHEN 0 THEN
CONVERT(DECIMAL(20,2), (CONVERT(DECIMAL, growth)/128))
END AS [next_auto_growth_size_MB]
, CASE mf.max_size
WHEN 0 THEN 'No growth is allowed'
WHEN -1 THEN 'File will grow until the disk is full'
ELSE CONVERT(VARCHAR, mf.max_size)
END AS [max_size]
from sys.master_files mf
WHERE 
--percentage growth and larger than 1 Gb
(mf.is_percent_growth = 1
AND CONVERT (DECIMAL (20,2) , (CONVERT(DECIMAL, size)/128))  > 1000)
--file growth and file size larger than file growth size
OR (mf.is_percent_growth = 0
AND  CONVERT (DECIMAL (20,2) , (CONVERT(DECIMAL, size)/128)) > CONVERT(VARCHAR, mf.growth/128 ))
ORDER BY 1
