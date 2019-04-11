--Verify that
--there's no SQL query in the application code produced by string concatenation.
--https://docs.microsoft.com/en-us/sql/relational-databases/security/sql-injection?view=sql-server-2017
--a high level check for statements that could produce dynamic SQL subject to injection
exec sp_MSforeachdb
'SELECT object_Name(id) FROM syscomments  
WHERE 
   UPPER(text) LIKE ''%EXECUTE (%''  
OR UPPER(text) LIKE ''%EXECUTE  (%''  
OR UPPER(text) LIKE ''%EXECUTE   (%''  
OR UPPER(text) LIKE ''%EXECUTE    (%''  
OR UPPER(text) LIKE ''%EXEC (%''  
OR UPPER(text) LIKE ''%EXEC  (%''  
OR UPPER(text) LIKE ''%EXEC   (%''  
OR UPPER(text) LIKE ''%EXEC    (%''  
OR UPPER(text) LIKE ''%SP_EXECUTESQL%'' ';