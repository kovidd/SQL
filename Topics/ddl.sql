-- INTO (Creates new table with selected fields)
DROP TABLE IF EXISTS aircraft_details;

SELECT s.seat_no, s.fare_conditions, a.model->>'en' as model, a.range
INTO aircraft_details
FROM seats s
JOIN aircrafts a
USING (aircraft_code)
LIMIT 5;

SELECT * FROM aircraft_details;

---------------------------------------------------------------------

-- GROUPING SETS (1 of 3 columns is not NULL, grouped 3 times)
SELECT seat_no, fare_conditions, model, AVG(range)
FROM aircraft_details
GROUP BY GROUPING SETS (1,2,3);

-- ROLLUP (1 of 3 columns is not NULL, grouped 3 times)
SELECT seat_no, fare_conditions, model, AVG(range)
FROM aircraft_details
GROUP BY ROLLUP (1,2,3);

-- CUBE (1 of 3 columns is not NULL, grouped 3 times)
SELECT seat_no, fare_conditions, model, AVG(range)
FROM aircraft_details
GROUP BY CUBE (1,2,3);

--
SELECT tf.ticket_no, tf.fare_conditions, tf.amount, s.seat_no, s.aircraft_code, a.model->>'en' as model
INTO _1st_50_aircraft_details
FROM ticket_flights tf
JOIN seats s
ON tf.fare_conditions = s.fare_conditions
JOIN aircrafts a
USING (aircraft_code)
LIMIT 50;

SELECT * FROM _1st_50_aircraft_details;

-- VIEW
CREATE VIEW aircrafts_eng AS
SELECT aircraft_code, model->>'en' AS model, range
FROM aircrafts;

SELECT * FROM aircrafts_eng;

--
-- Question : count the number of routes laid from the airports

-- Firstly, create VIEW called cities as the following:
CREATE VIEW cities AS 
SELECT (SELECT city ->> 'en' FROM airports WHERE airport_code =departure_airport) AS departure_city, 
	   (SELECT city ->> 'en' FROM airports WHERE airport_code =arrival_airport) AS arrival_city
FROM flights;
-- then :
SELECT departure_city, COUNT (*)
FROM cities
GROUP BY departure_city
HAVING departure_city IN (SELECT city->> 'en' FROM airports )
ORDER BY COUNT DESC;

-- COPY (Create file from db)
GRANT pg_read_server_files TO my_user WITH ADMIN OPTION;

COPY (
		SELECT aircraft_code, model->>'en' AS model, range 
		FROM aircrafts
		ORDER BY aircraft_code
	 )
TO 'D:\aircraft_details.csv'
DELIMITER ','
CSV HEADER;