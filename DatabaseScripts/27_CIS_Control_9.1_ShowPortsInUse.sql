--checks 9.1 Limit Open Ports, Protocols, and Services
--Ensure that only ports,protocols, and services with validated business needs are running
--on each system.

--find the ports the server is using

SELECT DISTINCT 
    local_tcp_port 
FROM sys.dm_exec_connections 
WHERE local_tcp_port IS NOT NULL 


