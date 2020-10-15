SELECT COUNT(*) AS "D1.7 Certificates known to DB"
FROM sys.certificates
WHERE name not like '##MS_%';