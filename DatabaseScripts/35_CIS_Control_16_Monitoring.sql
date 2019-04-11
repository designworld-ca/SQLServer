--CIS Control 16
--checks if database mail is in use which can be used to alert on unusual events
--there are other steps which must be done to make this useful so this is an initial check


EXECUTE msdb.dbo.sysmail_help_status_sp ;