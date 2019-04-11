--selects for system configurations of interest
--refers to CIS 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.15, 5.2

SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name IN (
'Ad Hoc Distributed Queries',
'clr enabled',
'cross db ownership chaining',
'Database Mail XPs',
'default trace enabled',
'Ole Automation Procedures',
'remote access',
'remote admin connections',
'scan for startup procs',
'xp_cmdshell'
)
order by name;
