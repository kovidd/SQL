-- SELECT * FROM flights LIMIT 5;

-- Max flight_id
-- SELECT MAX(flight_id) FROM flights;

-- Min flight_id
-- SELECT MIN(flight_id) FROM flights;

-- nth (5th) highest flight_id
WITH T AS
	(
		SELECT * ,
--    		DENSE_RANK() OVER (ORDER BY flight_id DESC) AS Rnk
   		DENSE_RANK() OVER (ORDER BY flight_id DESC) Rnk
		FROM flights
	)
SELECT * FROM T WHERE Rnk=2;

-- Another easier way to find the nth salary, using LIMIT and OFFSET
SELECT * FROM flights ORDER BY flight_id DESC LIMIT 1 OFFSET 4;

-- SELECT * FROM flights ORDER BY flight_id DESC LIMIT 5;

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