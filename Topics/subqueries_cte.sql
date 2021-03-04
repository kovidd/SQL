-- Find cities with more than 1 airport

SELECT a.airport_code, a.airport_name->>'en' as airport_name, a.city->>'en' as city
FROM 
	(SELECT city, COUNT(*)
	 FROM airports
	 GROUP BY city
	 HAVING COUNT(*) > 1
	)
AS subquery
JOIN airports a
ON subquery.city = a.city
ORDER BY a.city, airport_name;


-- Find all in-air flights departure and arrival airports and cities
SELECT f.flight_no, f.departure_airport as d_air, 
	   (SELECT city->>'en' FROM airports WHERE airport_code=f.departure_airport) AS d_city,
	   f.arrival_airport as a_air,
	   (SELECT DISTINCT city->>'en' FROM airports WHERE airport_code=f.arrival_airport) AS a_city
FROM flights f
WHERE status = 'Departed';

-------------------------------------------------------------------------------------------

-- EXISTS
SELECT * 
FROM ticket_flights
WHERE EXISTS (SELECT ticket_no FROM tickets);

-- Select boarding_passes with Business class seats from flights departing from Samara
SELECT *
FROM boarding_passes
WHERE EXISTS (SELECT flight_id FROM ticket_flights WHERE fare_conditions = 'Business')
  AND EXISTS (SELECT DISTINCT flight_id FROM flights 
			  WHERE (SELECT DISTINCT airport_code FROM airports WHERE city->>'en' = 'Samara') = departure_airport);
 
 
SELECT flight_no, status
FROM flights
WHERE EXISTS 
	(SELECT a.airport_code
	 FROM airports a
	 JOIN flights f
	 ON a.airport_code = f.arrival_airport
	)

AND EXISTS
	(SELECT a.airport_code
	 FROM airports a
	 JOIN flights f
	 ON a.airport_code = f.departure_airport
	);
	
-------------------------------------------------------------------------------------------

-- ANY
SELECT ticket_no, boarding_no, seat_no
FROM boarding_passes
WHERE flight_id = ANY (SELECT flight_id FROM ticket_flights WHERE fare_conditions = 'Business');

-- ALL
SELECT ticket_no, boarding_no, seat_no
FROM boarding_passes
WHERE flight_id = ALL (SELECT flight_id FROM ticket_flights WHERE fare_conditions = 'Business');

-------------------------------------------------------------------------------------------

-- CTE

-- Count the no of flights where aircraft range > 7000
SELECT COUNT(flight_id) 
FROM flights f, aircrafts a
WHERE f.aircraft_code = a.aircraft_code 
  AND a.range > 7000;
  
-- Another way to the above using CTE
WITH long_range AS (SELECT * FROM aircrafts WHERE range > 7000)
SELECT COUNT(*)
FROM flights f
JOIN long_range l 
ON f.aircraft_code = l.aircraft_code;

/*
-- CTE Syntax
WITH alias_name AS (SUBQUERY)
SELECT (#CONDITIONS) 
FROM TABLE t
JOIN alias_name ON t.id=alias_name.id;
*/

-- Find passenger and flight info for a booking ref 'A55664'
WITH pass_info AS (SELECT t.book_ref, f.flight_no, f.departure_airport dep,
				   f.arrival_airport arr, t.passenger_name, f.scheduled_departure
				   FROM tickets t
				   JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
				   JOIN flights f ON f.flight_id = tf.flight_id
		   	 	  )
SELECT * FROM pass_info
WHERE book_ref = 'A55664'
ORDER BY passenger_name, scheduled_departure;

-- Find airports, aircraft and num of seats occupying ratio for that aircraft
WITH t1 AS  (SELECT f.flight_id, f.flight_no, f.scheduled_departure,
			(SELECT city->>'en' FROM airports WHERE airport_code = f.departure_airport) AS departure_city,
			(SELECT city->>'en' FROM airports WHERE airport_code = f.arrival_airport) AS arrival_city,
		    f.aircraft_code, COUNT(tf.ticket_no) AS actual_passengers,
			(SELECT COUNT(s.seat_no) FROM seats s WHERE s.aircraft_code = f.aircraft_code) AS total_seats
			FROM flights f
			JOIN ticket_flights tf
			 ON f.flight_id = tf.flight_id
			 WHERE f.status = 'Arrived'
			 GROUP BY 1,2,3,4,5,6
			)

SELECT t1.flight_id, t1.flight_no, t1.scheduled_departure, t1.departure_city,
	   t1.arrival_city, a.model->>'en' AS model, t1.actual_passengers, t1.total_seats,
	   ROUND(t1.actual_passengers::NUMERIC/t1.total_seats::NUMERIC, 2) AS occupying_ratio
FROM t1
JOIN aircrafts AS a
ON t1.aircraft_code = a.aircraft_code
ORDER BY occupying_ratio;
-- Side note : Occupying ratio helps predict the aircraft needed for low capacity flights