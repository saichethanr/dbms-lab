DROP DATABASE IF EXISTS insurance;
CREATE DATABASE insurance;
USE insurance;

CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);

--Find the total number of people who owned cars that were involved in accidents in 2021.
select count(distinct p.driver_id) as total_no_of_people_accident_2021 from participated p join accident a on p.report_no=a.report_no where a.accident_date LIKE "2021%";
--Find the number of accidents in which the cars belonging to “Smith” were involved.
select count(distinct a.report_no) as no_accidents_smith from accident a join participated p on p.report_no=a.report_no join person pe on pe.driver_id=p.driver_id where pe.driver_name LIKE "Smith";
--Add a new accident to the database; assume any values for required attributes.
DELETE FROM car
WHERE reg_no IN (
    SELECT derived.reg_no
    FROM (
        SELECT c.reg_no
        FROM car c
        JOIN owns o ON c.reg_no = o.reg_no
        JOIN person p ON p.driver_id = o.driver_id
        WHERE p.driver_name LIKE 'Smith%' AND c.model="Swift"
    ) AS derived
);
--Update the damage amount for the car with license number “KA09MA1234” in the accident with report.
update participated set damage_amount=50000 where reg_no='KA-09-MA-1234';
--A view that shows models and year of cars that are involved in accident.
create view model_year_car as select c.model,c.c_year from car c join participated p on p.reg_no=c.reg_no;
--A trigger that prevents a driver from participating in more than 3 accidents in a given year.
DELIMITER ;
DELIMITER // ;
CREATE TRIGGER notmorethan3 before insert on participated for each row BEGIN 
IF 3<= ( select count(*) from participated where driver_id = NEW.driver_id) THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='NOOOOOO'; END IF; END; //

