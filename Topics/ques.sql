-- Questions

-- 1. List the cities in which there is no flights from Moscow ?
SELECT DISTINCT air.city->>'en' as City
FROM flights f, airports air
WHERE air.airport_code = f.departure_airport AND air.city->>'en' <> 'Moscow'
ORDER BY City;

-- Gives same result
SELECT DISTINCT a.city ->> 'en' as city
FROM airports a
WHERE a.city ->> 'en' <> 'Moscow'
ORDER BY city;

SELECT * FROM flights;
SELECT * FROM airports;


-- 2. Select airports in a time zone is in Asia / Novokuznetsk and Asia / Krasnoyarsk ?
SELECT * FROM airports
WHERE timezone IN ('Asia/Novokuznetsk', 'Asia/Krasnoyarsk')
ORDER BY airport_code;

-- 3. Which planes have a flight range in the range from 3,000 km to 6,000 km ?
SELECT * FROM aircrafts WHERE range BETWEEN 3000 AND 6000;

-- 4. Get the model , range,  and miles of every air craft exist in the Airlines database, 
--    notice that miles = range / 1.609  and round the result to 2 numbers after the float point?
SELECT model->>'en', range, round(range/1.609, 2) as miles FROM aircrafts;

-- Show cities with more than 1 airport
SELECT city->>'en', count(*)
FROM airports
GROUP BY city
HAVING count(*) > 1;

-- SUM, COUNT
-- 1. Calculate the Average tickets Sales?
SELECT AVG(total_amount) FROM bookings; -- 79025.60

-- 2. Return the number of seats in the air craft that has aircraft code = 'CN1' ?
SELECT COUNT(*) 
FROM seats s
WHERE s.aircraft_code = 'CN1';

-- 3. Return the number of seats in the air craft that has aircraft code = 'SU9'  ?
SELECT COUNT(*) 
FROM seats s
WHERE s.aircraft_code = 'SU9';

-- 4. Write a query to return the aircraft_code and the number of seats of 
--    each air craft ordered ascending?
SELECT aircraft_code, COUNT(*) as numseats
FROM seats
GROUP BY aircraft_code
ORDER BY numseats;

-- 5. calculate the number of seats in the salons for all aircraft models, 
--    but now taking into account the class of service Business class and Economic class.
SELECT aircraft_code, fare_conditions, COUNT(*) as numseats
FROM seats
GROUP BY aircraft_code, fare_conditions
ORDER BY aircraft_code;

-- 6. What was the least day in tickets sales?
SELECT * FROM bookings;

SELECT book_date, Sum(total_amount) AS sales, book_ref
FROM bookings
GROUP BY 1, 3
ORDER BY 2
LIMIT 1;

-- Another solution to Coding Quiz no 6 :
-- SELECT min (total_amount)
-- FROM bookings;

-- 1. Determine how many flights from each city to other cities, 
-- 	  return the the name of city and count of flights more than 50 
--    order the data from the largest no of flights to the least?
SELECT 
	(SELECT city ->> 'en' FROM airports WHERE airport_code=departure_airport)  AS departure_city, 
	COUNT(*) as numflights
FROM flights
GROUP BY departure_city
HAVING COUNT (*)>= 50
ORDER BY numflights DESC;

 -- (Below, finding cities with their number of airports)
SELECT city->>'en' as city, COUNT(airport_name) as numairports
FROM airports
GROUP BY 1
ORDER BY numairports DESC;

-- 2. Return all flight details in the indicated day 2017-08-28
--    include flight count ascending order and departures count and 
--    when departures happen in arrivals count and when arrivals happen?
-- SELECT f.flight_no,f.scheduled_departure :: time AS dep_time,
-- f.departure_airport AS departures,f.arrival_airport AS arrivals,
-- count (flight_id)AS flight_count
-- FROM flights f
-- WHERE f.departure_airport = 'KZN'
-- AND f.scheduled_departure >= '2017-08-28' :: date
-- AND f.scheduled_departure <'2017-08-29' :: date
-- GROUP BY 1,2,3,4,f.scheduled_departure
-- ORDER BY flight_count DESC,f.arrival_airport,f.scheduled_departure;

-- Write a query to arrange the range of model of air crafts so
-- Short range is less than 2000, 
-- Middle range is more than 2000 and less than 5000 & 
-- any range above 5000 is long range?
SELECT * FROM aircrafts;

SELECT *,
CASE WHEN range < 2000 THEN 'Short Range'
	 WHEN range BETWEEN 2000 AND 5000 THEN 'Middle Range'
	 ELSE 'Long Range' 
	 END range_criteria
FROM aircrafts
ORDER BY range;

-- What is the shortest flight duration for each possible flight from Moscow to St. Petersburg, 
-- and how many times was the flight delayed for more than an hour?
SELECT * FROM flights;
SELECT * FROM airports;
SELECT airport_code, city->>'en'
FROM airports
WHERE city->>'en' = 'Moscow' OR city->>'en' = 'St. Petersburg'; 
-- Peter = LED, Moscow = SVO, VKO, DME

-- Find flights between airports in Moscow to airports in St. Peter
SELECT * 
FROM flights f
WHERE (SELECT city->>'en' FROM airports WHERE airport_code = departure_airport) = 'Moscow'
AND   (SELECT city->>'en' FROM airports WHERE airport_code = arrival_airport) = 'St. Petersburg'
AND f.status = 'Arrived';

-- Full answer to the question
SELECT f.flight_no, 
	(f.Scheduled_arrival - f.Scheduled_departure) AS scheduled_duration,
	min(f.Scheduled_arrival - f.Scheduled_departure), 
	max(f.Scheduled_arrival - f.Scheduled_departure),
	sum(CASE WHEN f.actual_departure > f.scheduled_departure + INTERVAL '1 hour' THEN 1 ELSE 0 END) delays
FROM flights f
WHERE (SELECT city ->> 'en' FROM airports WHERE airport_code = departure_airport) = 'Moscow'
AND (SELECT city ->> 'en' FROM airports WHERE airport_code = arrival_airport) = 'St. Petersburg'
AND f.status = 'Arrived'
GROUP BY f.flight_no, (f.Scheduled_arrival - f.Scheduled_departure);

------------------------------------------------------------
-- General Q : Whats the output of the following :
SELECT CASE WHEN NULL = NULL THEN 'YES' ELSE 'NO' END; -- NO
SELECT CASE WHEN 1 = 1 THEN 'YES' ELSE 'NO' END; -- YES

SELECT 1/2 AS res; --0

-- BEGIN TRY
-- 	SELECT 'foo' AS res;
-- END TRY
-- BEGIN CATCH
-- 	SELECT 'bar' AS res;
-- END CATCH;

SELECT 'abc\def' AS result; -- abc\def
------------------------------------------------------------

-- 1. How many people can be included into a single booking 
--    according to the available data?


-- 2. Which combinations of first and last names occur most 
--    often? What is the ratio of the passengers with such names
--    to the total number of passengers?


-- CTE Challenges
-- 1. What are the maximum and minimum ticket prices in all directions?


-- 2. Get a list of airports in cities with more than one airport ?
WITH t1 AS (SELECT airport_code, city FROM airports)
SELECT city->>'en' AS city, COUNT(*)
FROM t1
GROUP BY city
HAVING COUNT(*) > 1;

-- 3. What will be the total number of different routes that are 
--    theoretically can be laid between all cities?




-- Question : count the number of routes laid from the airports

-- Firstly, create VIEW called cities as the following:
CREATE VIEW cities AS 
SELECT (SELECT city ->> 'en' FROM airports WHERE airport_code=departure_airport) AS departure_city, 
	   (SELECT city ->> 'en' FROM airports WHERE airport_code=arrival_airport) AS arrival_city
FROM flights;
-- then :
SELECT departure_city, COUNT (*)
FROM cities
GROUP BY departure_city
HAVING departure_city IN (SELECT city->> 'en' FROM airports )
ORDER BY COUNT DESC;


-- Final Questions --
-- 1. For each ticket, display all the included flight segments, 
-- 	together with connection time. Limit the result to the tickets booked a week ago?
-- Ans:
SELECT tf.ticket_no, f.departure_airport, f.arrival_airport, f.scheduled_arrival,
lead(f.scheduled_departure) OVER w AS next_departure,
lead(f.scheduled_departure) OVER w - f.scheduled_arrival AS gap
FROM bookings b
JOIN tickets t
ON t.book_ref = b.book_ref
JOIN ticket_flights tf
ON tf.ticket_no = t.ticket_no
JOIN flights f
ON tf.flight_id = f.flight_id
WHERE b.book_date = public.now()::date - INTERVAL '7 day'
WINDOW w AS (PARTITION BY tf.ticket_no ORDER BY f.scheduled_departure);

-- 2. Find the most disciplined passengers who checked in first for all their flights. 
-- 	Take into account only those passengers who took at least two flights
-- Ans:
SELECT t.passenger_name, t.ticket_no
FROM tickets t
JOIN boarding_passes bp
ON bp.ticket_no = t.ticket_no
GROUP BY t.passenger_name,t.ticket_no
HAVING max(bp.boarding_no) = 1 AND count(*) > 1;



-- 3. Which flights had the longest delays?
-- Ans:
SELECT f.flight_no,  f.scheduled_departure, f.actual_departure,
	   (f.actual_departure - f.scheduled_departure) AS delay
FROM  flights f
WHERE f.actual_departure IS NOT NULL
ORDER BY f.actual_departure - f.scheduled_departure ;


-- 4. How many seats remained free on flight PG0404 in the day before 
-- 	the last in the airlines database?
-- Ans:
SELECT count(*)
FROM (SELECT s.seat_no FROM  seats s
  WHERE s.aircraft_code = (SELECT aircraft_code
   FROM  flights
   WHERE flight_no = 'PG0404'
   AND scheduled_departure::date = public.now()::date - INTERVAL '1 day')
      EXCEPT
      SELECT bp.seat_no
      FROM boarding_passes bp
      WHERE bp.flight_id = (SELECT flight_id
							FROM  flights
							WHERE flight_no = 'PG0404'
							AND scheduled_departure::date = public.now()::date - INTERVAL '1 day')) t; 

-- 5. How many seats remained free on flight PG0404 in the day before 
-- 	the last in the airlines database?
-- Ans:
SELECT count(*)
FROM flights f
JOIN seats s
ON s.aircraft_code = f.aircraft_code
WHERE f.flight_no = 'PG0404'
AND f.scheduled_departure::date = public.now()::date - INTERVAL '1 day'
AND NOT EXISTS (SELECT NULL FROM boarding_passes bp
WHERE bp.flight_id = f.flight_id AND bp.seat_no = s.seat_no);


-- 6. What is the different between the tables created using VIEWS 
-- 	and the tables created using SELECT INTO ?
-- Ans:
-- * SELECT INTO created a table that is structured with a set number of 
-- columns and a boundless number of columns so you can apply all the SQL 
-- querying commands on the the resulted table.
-- * But VIEWS is treated as  virtual tables that is extracted from a database
-- So you cannot apply all the SQL querying commands on the the resulted table as joins.

-----------------------------------------------
SELECT * FROM flights
FETCH FIRST 10 ROWS ONLY;
