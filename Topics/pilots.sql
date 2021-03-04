-- Create table Pilots

CREATE TABLE IF NOT EXISTS pilots (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	speciality TEXT NOT NULL,
	age TEXT,
	sex TEXT NOT NULL
);
/*
-- insert
INSERT INTO pilots (name, speciality, age)
VALUES ('John', 'cessna pilot', '50'),
	   ('Sara', 'co-pilot', '30'),
	   ('Mark', 'pilot', NULL);
*/

-- Extract all
SELECT * FROM pilots; --9
SELECT COUNT(*) FROM pilots; --9
SELECT COUNT(age) FROM pilots; --6

-- Aggregate Functions
SELECT COUNT(passenger_name) FROM tickets; --366733
SELECT COUNT(DISTINCT passenger_name) FROM tickets; --22220

SELECT SUM(total_amount) FROM bookings; -- 20766980900.00
SELECT AVG(total_amount) FROM bookings; -- 79025.60
SELECT MIN(total_amount) FROM bookings; -- 3400.00
SELECT MAX(total_amount) FROM bookings; -- 1204500.00

SELECT *,
CASE WHEN age >= '50' THEN 'old'
     WHEN age ISNULL THEN 'unknown'
	 ELSE 'young' END ageism
FROM pilots;