--returns product, version, cluster and security levels
--refers to CIS Benchmark 1.1 and 1.2 and 3.1
USE master;
GO

SELECT SERVERPROPERTY('ProductLevel') as SP_installed,
SERVERPROPERTY('ProductVersion') as Version,
SERVERPROPERTY('IsClustered') as Cluster,
SERVERPROPERTY('IsIntegratedSecurityOnly') as login_mode;

