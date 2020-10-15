--shows if the certificate has been backed up, if null is returned then a backup has not happened
SELECT pvt_key_last_backup_date,
       Db_name(dek.database_id) AS encrypteddatabase, c.name AS Certificate_Name 
FROM   sys.certificates c
       INNER JOIN sys.dm_database_encryption_keys dek
         ON c.thumbprint = dek.encryptor_thumbprint 
