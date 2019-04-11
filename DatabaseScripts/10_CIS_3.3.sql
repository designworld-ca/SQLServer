--verifies CIS Benchmark 3.3 no orphaned users
--check for orphan users
exec sp_MSforeachdb
'EXEC sp_change_users_login @Action=''Report'''

