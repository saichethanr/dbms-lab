drop database if exists sailors;

create database sailors;
use sailors;

create table if not exists Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);


insert into Boat values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

select * from Sailors;
select * from Boat;
select * from reserves;

--Find the colours of boats reserved by Albert
select b.color from Boat b join reserves r on r.bid = b.bid join Sailors s on r.sid=s.sid where s.sname LIKE "Albert";
--Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
(select sid from Sailors where rating>=8) UNION (select s.sid from Sailors s join reserves r on s.sid=r.sid and r.bid=103);
--Find the names of sailors who have not reserved a boat whose name contains the string“storm”. Order the names in ascending order.
 select s.sname from Sailors s where s.sid not in (select r.sid from reserves r where r.sid=s.sid) and s.sname LIKE "%storm%" order by s.sname ASC;
--select sailor name who has reserved all the boats (**)
select s.sname from Sailors s where not exists ( select b.bid from Boat b where not exists (select r.bid from reserves r where r.sid=s.sid and r.bid=b.bid));
--find the oldetst sailor
select s.sname from Sailors s where s.age=(select MAX(age) from Sailors);
--For each boat which was reserved by at least 2 sailors with age >= 40, find the boat id andthe average age of such sailors. (**)
select r.bid,AVG(s.age) from reserves r join Sailors s on r.sid=s.sid where s.age>=40 group by r.bid having COUNT(DISTINCT r.sid)>=2;
--Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view boatdet as select b.bname,b.color from Boat b join reserves r on r.bid=b.bid join Sailors s on s.sid=r.sid where s.rating=5;
--A trigger that prevents boats from being deleted If they have active reservations.
DELIMITER // ;
CREATE TRIGGER checkanddel
BEFORE DELETE on Boat
FOR EACH ROW
BEGIN
IF EXISTS (SELECT * FROM reserves r where r.bid=OLD.bid) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='boat is reserved'; END IF; END; //
DELIMITER ;
