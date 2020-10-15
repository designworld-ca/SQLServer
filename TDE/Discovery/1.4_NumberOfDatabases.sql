--counting MS databases
select count(*) 
from sys.databases
where database_id > 4
