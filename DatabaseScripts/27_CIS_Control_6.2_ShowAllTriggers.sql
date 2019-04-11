--covers edge case of triggers used for auditing
--verifies CIS Control 6.2 Ensure Audit Log Settings Support Appropriate Log Entry Formatting
--
--lists all triggers, may produce extensive output depending on application development style
--
exec sp_MSforeachdb 
 'SELECT  name, object_id, schema_id, parent_object_id, type_desc, create_date, modify_date, is_published  
FROM sys.objects  
WHERE type = ''TR''' 
GO 
