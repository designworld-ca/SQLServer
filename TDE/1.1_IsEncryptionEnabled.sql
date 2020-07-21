SELECT
    db.name,
    db.is_encrypted,
    dm.encryption_state --where 3 is encrypted and 0 might or might not be
FROM
    sys.databases db
    LEFT OUTER JOIN sys.dm_database_encryption_keys dm
        ON db.database_id = dm.database_id;
GO
