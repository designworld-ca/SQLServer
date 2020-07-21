-- source: https://jasonbrimhall.info/2012/11/20/last-known-good-checkdb

CREATE TABLE #temp (
       Id INT IDENTITY(1,1), 
       ParentObject VARCHAR(255),
       [Object] VARCHAR(255),
       Field VARCHAR(255),
       [Value] VARCHAR(255)
)
 
CREATE TABLE #DBCCRes (
       Id INT IDENTITY(1,1)PRIMARY KEY CLUSTERED, 
       DBName sysname ,
       dbccLastKnownGood DATETIME,
       RowNum	INT
)
 
DECLARE
	@DBName SYSNAME,
	@SQL    varchar(512);
 
DECLARE dbccpage CURSOR
	LOCAL STATIC FORWARD_ONLY READ_ONLY
	FOR Select name
		from sys.databases
		where name not in ('tempdb');
 
Open dbccpage;
Fetch Next From dbccpage into @DBName;
While @@Fetch_Status = 0
Begin
Set @SQL = 'Use [' + @DBName +'];' +char(10)+char(13)
Set @SQL = @SQL + 'DBCC Page ( ['+ @DBName +'],1,9,3) WITH TABLERESULTS;' +char(10)+char(13)
 
INSERT INTO #temp
	Execute (@SQL);
Set @SQL = ''
 
INSERT INTO #DBCCRes
        ( DBName, dbccLastKnownGood,RowNum )
	SELECT @DBName, VALUE
			, ROW_NUMBER() OVER (PARTITION BY Field ORDER BY Value) AS Rownum
		FROM #temp
		WHERE field = 'dbi_dbccLastKnownGood';
 
TRUNCATE TABLE #temp;
 
Fetch Next From dbccpage into @DBName;
End
Close dbccpage;
Deallocate dbccpage;
 
SELECT DBName,dbccLastKnownGood
	FROM #DBCCRes
	WHERE RowNum = 1;
 
DROP TABLE #temp
DROP TABLE #DBCCRes
GO
 
/* Now Restore the database */
DECLARE @BackupPath VARCHAR(256)
	,@BackupName VARCHAR(50)
SET @BackupPath = 'C:\Database\Backup\' --replace with valid file path
SET @BackupName = 'TestB.bak'
 
SET @BackupPath = @BackupPath + @BackupName
/* for this contrived example, i will not take a tail log backup
and just use replace instead */
 
RESTORE DATABASE TestB
	FROM DISK = @BackupPath
	WITH REPLACE; 
GO
 
/* Rerun The Boot Page Check */
CREATE TABLE #temp (
       Id INT IDENTITY(1,1), 
       ParentObject VARCHAR(255),
       [Object] VARCHAR(255),
       Field VARCHAR(255),
       [Value] VARCHAR(255)
)
 
INSERT INTO #temp
EXECUTE ('DBCC Page ( TestB,1,9,3) WITH TABLERESULTS');
 
/* You will get two results from the following query */
SELECT *
	FROM #temp
	WHERE Field = 'dbi_dbccLastKnownGood';
 
/* TAKE note OF the date returned by the last query */
 
DROP TABLE #temp;
GO