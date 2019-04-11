--list database owners
--best practice is sa account when disabled or a no privilege disabled user

select suser_sname(owner_sid) from sys.databases;
