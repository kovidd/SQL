-- CAST (Typecasting) --
SELECT CAST('5 hours' AS INTERVAL); -- 05:00:00
SELECT CAST('6 days' AS INTERVAL); -- 6 days
SELECT CAST('11 months' AS INTERVAL); -- 11 mons
SELECT CAST('12 months' AS INTERVAL); -- 1 year

SELECT '6 days'::INTERVAL; -- 6 days
SELECT '12 months'::INTERVAL; -- 1 year

-- Typecasting continued :
DROP TABLE city;

CREATE TABLE IF NOT EXISTS city (
	id SERIAL PRIMARY KEY,
	zipcode INT NOT NULL,
	ville TEXT NOT NULL
);

-- TRUNCATE city;
INSERT INTO city (id, zipcode, ville)
VALUES (1, 1234, 'Paris'),
	   (2, 9870, 'Delhi'),
	   (3, 9873, 'Egypt'),
	   (4, 5670, 'Egypt'),
	   (5, 9876, 'Delhi');

-- SELECT cities with zipcodes units place
SELECT MOD(CAST(zipcode AS int), 10) FROM city; -- 4, 0, 3 , 0, 6

-- SELECT cities with zipcodes not ending in 0
SELECT * FROM city WHERE MOD(CAST(zipcode AS int), 10) <> 0;

-- SELECT cities with zipcodes to be ending in 0
SELECT DIV(CAST(zipcode AS int), 10), DIV(CAST(zipcode AS int), 10) * 10  FROM city;

-- If values are integers
UPDATE city SET zipcode = DIV(CAST(zipcode AS int), 10) * 10
WHERE MOD(CAST(zipcode AS int), 10) <> 0;

-- If values should be converted to string and back to int
UPDATE city
SET zipcode = CAST (CONCAT( LEFT(CAST(zipcode AS TEXT), LENGTH(CAST(zipcode AS TEXT))-1) , '0')  AS INT)
WHERE RIGHT(CAST(zipcode AS TEXT), 1) <> '0';

-- If values are in string
UPDATE city
SET zipcode = CONCAT(LEFT(zipcode, LENGTH(zipcode)-1), '0')
WHERE RIGHT(zipcode, 1) <> '0';

-- CAST ends --

--------------------------------------------------------------------------------------

-- Nth highest flight_id --

-- Max flight_id
SELECT MAX(flight_id) FROM flights;

-- Min flight_id
SELECT MIN(flight_id) FROM flights;

-- nth (5th) highest flight_id
WITH alias_name AS
	(
		SELECT * ,
   		DENSE_RANK() OVER (ORDER BY flight_id DESC) AS Rnk
		FROM flights
	)
SELECT * FROM alias_name WHERE Rnk=2;

-- Another easier way to find the nth flight_id, using LIMIT and OFFSET
SELECT * FROM flights ORDER BY flight_id DESC LIMIT 1 OFFSET 4;

-- Nth rank ends --

--------------------------------------------------------------------------------------

-- DATE_PART --
-- Select bookings withing date range May and July 2017
SELECT * 
FROM bookings
WHERE book_date BETWEEN TO_DATE ('05/01/2017 09:00:00 AM', 'mm/dd/yyyy hh:mi:ss AM')
                    AND TO_DATE ('07/31/2017 10:00:00 AM', 'mm/dd/yyyy hh:mi:ss AM')
ORDER BY book_date;
 
-- Easier way
SELECT * 
FROM bookings
WHERE book_date BETWEEN '2017/05/01 09:00:00 AM' AND '2017/07/31 10:00:00 AM'
ORDER BY book_date;

-- Also, TO_CHAR can be used to convert timestamp into string
-- Even easier
SELECT * 
FROM bookings
WHERE book_date BETWEEN '2017/05/01%' AND '2017/07/31%'
ORDER BY book_date;

-- Bookings on July 30 and 31st
SELECT * 
FROM bookings
WHERE book_date IN ('2017/07/30%', '2017/07/31%')
ORDER BY book_date;

-- 
SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS bookings,
CASE WHEN SUM(total_amount) > 6923152600.00 THEN 'the most'
	 WHEN SUM(total_amount) < 6923152600.00 THEN 'the least'
	 ELSE 'the medium' END AS booking_qt
FROM bookings
GROUP BY month
ORDER BY bookings;

-- Date-Part ends--

--------------------------------------------------------------------------------------

-- IS NULL and COALESCE

-- Using ISNULL and IS NOT NULL
SELECT * FROM flights
WHERE actual_departure IS NOT NULL AND
	  actual_arrival   IS NOT NULL
ORDER BY flight_id; 

SELECT * FROM flights
WHERE actual_departure ISNULL AND
	  actual_arrival   ISNULL
ORDER BY flight_id; 

-- Counting null and not null values (also by subtracting)
SELECT COUNT(*) FROM flights; -- 33121

SELECT COUNT(NULLIF(actual_departure, NULL)) count1, COUNT(NULLIF(actual_arrival, NULL)) count2
FROM flights; -- 16773, 16715

SELECT COUNT(*) - COUNT(NULLIF(actual_departure, NULL)) count1, 
	   COUNT(*) - COUNT(NULLIF(actual_arrival, NULL)) count2
FROM flights; -- 16348, 16406
-- here we can see, 16348+16773=33121, also 16406+16715=33121

-- COALESCE
SELECT status, actual_departure, actual_arrival
FROM flights;

SELECT status, COALESCE(actual_departure), COALESCE(actual_arrival)
FROM flights;

SELECT status, COALESCE(actual_departure, current_timestamp), COALESCE(actual_arrival, current_timestamp)
FROM flights;

-- ISNULL COALESCE Ends --

--------------------------------------------------------------------------------------

-- FETCH Example
SELECT * 
FROM boarding_passes
-- FETCH FIRST 10 ROWS ONLY;
FETCH FIRST ROW ONLY;

-- TOP 10 (DESC) ticket_nos
SELECT DISTINCT * FROM boarding_passes
ORDER BY ticket_no DESC
LIMIT 10;

-- Using window function
SELECT DISTINCT * FROM
	(SELECT *,
     RANK() OVER (ORDER BY ticket_no DESC) AS my_rank
	 FROM boarding_passes
	) subquery
WHERE my_rank <= 10
ORDER BY my_rank;

--------------------------------------------------------------------------------------

-- JsonB and LIKE

-- Select airports with english models (json values)
SELECT airport_code, airport_name->'en', city->'en', coordinates, timezone
FROM airports LIMIT 10;

-- Select Moscow city airports
-- -> gives a string output, ->> gives a text output
SELECT airport_code, airport_name->'en', city->'en', coordinates, timezone
FROM airports
WHERE city->>'en' = 'Moscow';

-- Select Moscow city airports
SELECT airport_code, airport_name->>'en', city->>'en', coordinates, timezone
FROM airports
WHERE city->>'en' = 'Moscow';

-- Select airports in Asia timezone
SELECT airport_code, airport_name->>'en', city->>'en', coordinates, timezone
FROM airports
WHERE timezone LIKE '%Asia%';

-- Select aircrafts with english models
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range FROM aircrafts LIMIT 10;

-- Select Airbus aircrafts with 200 in their model name
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range 
FROM aircrafts
WHERE model->>'en' LIKE '%Airbus%200%';

-- Select aircrafts with bus in their model name after 3 characters
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range 
FROM aircrafts
WHERE model->>'en' LIKE '___bus%';

-- Extract no. of airplanes
Select * FROM aircrafts;
Select COUNT(*) FROM aircrafts;

--------------------------------------------------------------------------------------

-- General Questions:
CREATE TABLE IF NOT EXISTS runners
	( id INT PRIMARY KEY,
	  name TEXT NOT NULL
	)
	
CREATE TABLE IF NOT EXISTS races
	( id INT PRIMARY KEY,
	  event TEXT NOT NULL,
	  winner_id TEXT
	)
	
DROP TABLE runners;

INSERT INTO runners(id, name)
	VALUES(1, 'John Doe'),
		  (2, 'Jane Doe'),
		  (3, 'Alice Jones'),
		  (4, 'Lisa Romero'),
		  (5, 'Bobby Lewis');
		  
INSERT INTO races(id, event, winner_id)
	VALUES(1, '100 mtr', 2),
		  (2, '500 mtr', 3),
		  (3, 'Cross country', 2),
		  (4, 'Triathlon', NULL);
		  
SELECT * FROM runners;
SELECT * FROM races;
SELECT winner_id FROM races;

SELECT * FROM runners WHERE id NOT IN (SELECT winner_id FROM races); -- error

SELECT DISTINCT winner_id FROM races WHERE winner_id IS NOT NULL;

SELECT * 
FROM runners 
WHERE CAST(id AS TEXT) NOT IN (SELECT DISTINCT winner_id FROM races WHERE winner_id IS NOT NULL);


--
DROP TABLE invoices;
CREATE TABLE invoices
	(Id INT PRIMARY KEY,
	 BillingDate DATE,
	 CustomerId INT	 
	);
INSERT INTO invoices(Id, BillingDate, CustomerId)
VALUES (1, '22-02-2021', 2),
	   (2, '21-02-2021', 4),
	   (3, '20-02-2021', 1),
	   (4, '23-02-2021', 3),
	   (5, '24-02-2021', 5),
	   (6, '25-02-2021', 6);
	   
SELECT * FROM customers;
SELECT * FROM invoices;

SELECT c.name as CustomerName, r.name as ReferralName
FROM customers c
LEFT JOIN customers r
ON c.referredby = r.id;

-- For each invoice, show the Invoice ID, the billing date, the customer’s name, 
-- and the name of the customer who referred that customer (if any). 
-- The list should be ordered by billing date.
SELECT i.id, i.billingdate, c.name as CustomerName, r.name as ReferralName
FROM invoices i
JOIN customers c
ON i.Id = CAST(c.id AS INT)
LEFT JOIN customers r
ON c.referredby = r.id
ORDER BY i.billingdate;

-- Write a query to add 2 where Nmbr is 0 and add 3 where Nmbr is 1.
SELECT * FROM tbl;
SELECT CASE WHEN id=0 THEN id+2 ELSE id+3 END 
FROM tbl;

-- Write a query to to get the list of users who took the a training lesson 
-- more than once in the same day, grouped by user and training lesson,
-- each ordered from the most recent lesson date to oldest date.
CREATE TABLE user_details
	(user_id INT PRIMARY KEY, 
	 username TEXT);

CREATE TABLE training_details
	(user_training_id INT PRIMARY KEY, 
	 user_id INT,
	 training_id INT,
	 training_date DATE);

INSERT INTO	user_details (user_id, username)
VALUES (1, 'John Doe'),                                                                                        
	   (2, 'Jane Don'),                                                                                        
	   (3, 'Alice Jones'),                                                                                         
  	   (4, 'Lisa Romero');
	   
INSERT INTO	training_details (user_training_id, user_id, training_id, training_date)
VALUES (1 , 1, 1, '2015-08-02'),
	(2 , 2, 1, '2015-08-03'),
	(3 , 3, 2, '2015-08-02'),
	(4 , 4, 2, '2015-08-04'),
	(5 , 2, 2, '2015-08-03'),
	(6 , 1, 1, '2015-08-02'),
	(7 , 3, 2, '2015-08-04'),
	(8 , 4, 3, '2015-08-03'),
	(9 , 1, 4, '2015-08-03'),
	(10, 3, 1, '2015-08-02'),
	(11, 4, 2, '2015-08-04'),
	(12, 3, 2, '2015-08-02'),
	(13, 1, 1, '2015-08-02'),
	(14, 4, 3, '2015-08-03');
	
SELECT user_training_id, user_id, training_id, training_date
FROM training_details
GROUP BY 1,2,4
ORDER BY 1;

-- Number of users per day
SELECT COUNT(user_id), training_date
FROM training_details
GROUP BY 2
ORDER BY 2;

-- Number of lesson per day per user
SELECT user_id, training_date, COUNT(training_date) as count
FROM training_details
GROUP BY 1,2
ORDER BY 1;

-- Number of users per day having count > 1
SELECT user_id, training_id, training_date, COUNT(training_date) as count
FROM training_details
GROUP BY 1, 2, 3
HAVING COUNT(training_date) > 1
ORDER BY training_date;

-- Join the 2 tables
SELECT * FROM user_details;

EXPLAIN
SELECT u.user_id, u.username, t.training_id, t.training_date, COUNT(t.training_date) as count
FROM user_details u
JOIN training_details t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.username, t.training_id, t.training_date
HAVING COUNT(t.training_date) > 1
ORDER BY t.training_date DESC;

-- Get usernames in 1 line seperated by ;
-- This is PostgreSQL specific
SELECT array_to_string(array_agg(username), '; '::text) 
FROM user_details;

SELECT REGEXP_SPLIT_TO_TABLE('C A P O N E', '(\s)') AS split_table;
SELECT REGEXP_SPLIT_TO_TABLE('CAPONE', '[A-Z]') AS split_table;

-- 
WITH t AS (SELECT user_id FROM user_details)
SELECT SUM(1) FROM t; -- 4

WITH t AS (SELECT user_id FROM user_details)
SELECT SUM(2) FROM t; -- 8

WITH t AS (SELECT user_id FROM user_details)
SELECT SUM(3) FROM t; -- 12

-- Select rows that have a 'John Doe' in either of the columns
SELECT * 
FROM user_details
WHERE 'John Doe' IN (CAST(user_id AS text), username);

WITH t AS (SELECT user_id FROM user_details)
SELECT 
user_id AS user_id
!user_id AS opposite_user_id
FROM t;

---------------------------------------------------------------

-- Find sum of all positive and negative values
SELECT * FROM tbl;

SELECT SUM(CASE WHEN id > 0 THEN id ELSE 0 END) AS pos_sum,
	   SUM(CASE WHEN id < 0 THEN id ELSE 0 END) AS neg_sum
FROM tbl;
		

-- DUPLICATES
SELECT * FROM user_details;

ALTER TABLE user_details
DROP COLUMN email;

-- Changing a Column's Default Value 
ALTER TABLE user_details
ADD COLUMN email TEXT NOT NULL DEFAULT 'user@gmail.com';

-- Changing a Column's Default Value to first name
UPDATE user_details
SET email = LOWER(SUBSTRING(username FROM '(^\S*)') || '@gmail.com');

-- Changing a Column's Default Value to last name
UPDATE user_details
SET email = LOWER(SUBSTRING(username FROM '(?<=\s).*') || '@gmail.com');

DELETE FROM user_details WHERE user_id = 5;

INSERT INTO user_details (user_id, username, email)
VALUES (5, 'John Doe', 'doe@gmail.com');

SELECT * FROM user_details;

-- Duplicate records with one field
SELECT ROW_NUMBER() OVER(ORDER BY username, email), username, COUNT(email) 
FROM user_details
GROUP BY username, email
HAVING COUNT(email) > 1;

-- Duplicate records with more than one field
SELECT username, email, COUNT(*)
FROM user_details
GROUP BY username, email
HAVING COUNT(*) > 1;

