--covers CIS Control 9.5 no excess tooling such as sample schemas are installed

select * from sys.databases 
WHERE UPPER(name) LIKE ('NORTHWIND%')
OR UPPER(name) LIKE ('ADVENTURE%')
OR UPPER(name) LIKE ('CONTOSO%');