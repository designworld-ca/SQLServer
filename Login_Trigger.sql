--CHANGE DB NAME as required
--logon trigger used with a dedicated table
--this information is also shown in the event log if you configure SQL Server to do so but is hard to manage with so many other entries

USE master
GO

CREATE TABLE LogonAudit
(
    AuditID INT NOT NULL CONSTRAINT PK_LogonAudit_AuditID 
                PRIMARY KEY CLUSTERED IDENTITY(1,1)
    , UserName NVARCHAR(255)
    , LogonDate DATETIME
    , spid INT NOT NULL
);
GO
GRANT INSERT ON master.dbo.LogonAudit TO public;
GO

ALTER TRIGGER LoginTrigger ON ALL SERVER FOR LOGON
AS 
BEGIN
    IF SUSER_SNAME() NOT IN ('sa', 'HYDRO\SPFarmDev', 'HYDRO\SPSearchSvcDev', 'HYDRO\SPAdminDev', 'RMTAdmin')
    INSERT INTO LogonAudit (UserName, LogonDate, spid) 
            VALUES (SUSER_SNAME(), GETDATE(), @@SPID);
END;
GO
ENABLE TRIGGER LoginTrigger ON ALL SERVER;
GO                                                                                                                         
