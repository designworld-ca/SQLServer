--only works on 2008 and newer and only available on Enterprise version
--shows whether TDE encryption is in use and what cipher strength
--values for db.is_encrypted are 1 for encrypted, for dm.encryption_state a value of 2 indicates encryption is in progress 
--and 3 indicates that encryption is complete
--see https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/transparent-data-encryption?view=sql-server-2017
USE master; 
GO
 
SELECT 
    db.name,
    db.is_encrypted,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm,
    dm.key_length
FROM 
    sys.databases db
    LEFT OUTER JOIN sys.dm_database_encryption_keys dm
        ON db.database_id = dm.database_id;
GO
