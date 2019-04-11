--checks CIS control 9.1 Limit open ports, protocols and services
--used to query the linked servers and user logins:

exec sp_linkedservers;

select * from sys.servers;

select * from  sys.linked_logins;
