--checks 9.1 Limit Open Ports, Protocols, and Services
--another check to ensure that only ports,protocols, and services with validated business needs are running
--on each system.

--find the port the server is using in case it is dynamic

select * from sys.dm_tcp_listener_states


