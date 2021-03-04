-- Join seats and aircrafts
SELECT * FROM aircrafts;

-- INNER JOIN is same as JOIN
SELECT a.model->>'en' as model, s.seat_no, s.fare_conditions 
FROM seats s
JOIN aircrafts a
ON s.aircraft_code = a.aircraft_code
WHERE a.model->>'en' LIKE 'Airbus A320%';

-- SELF JOIN (Same as above)
SELECT a.model->>'en' as model, s.seat_no, s.fare_conditions
FROM seats s, aircrafts a
WHERE a.model->>'en' LIKE 'Airbus A320%' AND s.aircraft_code = a.aircraft_code;

-- Join flights as well
SELECT * FROM flights;
SELECT a.model->>'en' as model, s.seat_no, s.fare_conditions,
	   f.flight_no, f.departure_airport, f.arrival_airport
FROM seats s
JOIN aircrafts a
ON s.aircraft_code = a.aircraft_code
JOIN flights f
ON f.aircraft_code = a.aircraft_code
WHERE a.model->>'en' LIKE 'Airbus%';

-- Create 2 tables to understand joins
-- CREATE TABLE IF NOT EXISTS customer (
-- 	id SERIAL PRIMARY KEY,
-- 	name TEXT NOT NULL,
-- 	age TEXT NOT NULL,
-- 	sex TEXT NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS staff (
-- 	id SERIAL PRIMARY KEY,
-- 	name TEXT NOT NULL,
-- 	age TEXT NOT NULL,
-- 	sex TEXT NOT NULL
-- );

-- INSERT INTO customer (name, age, sex)
-- VALUES ('John', '50', 'M'),
-- 	   ('Sara', '30', 'F'),
-- 	   ('Mark', '25', 'M');

-- INSERT INTO staff (name, age, sex)
-- VALUES ('John', '50', 'M'),
-- 	   ('Emma', '27', 'F'),
-- 	   ('Laura', '35', 'F');

SELECT * FROM staff;
SELECT * FROM customer;
-- TRUNCATE TABLE staff; --delete all rows
-- TRUNCATE TABLE customer; --delete all rows

-- DROP TABLE staff; --delete
-- DROP TABLE customer; --delete

-- Combination of staff X customer
SELECT * 
FROM staff
CROSS JOIN customer;

-- Only staff
SELECT * 
FROM staff s
LEFT JOIN customer c
ON s.name = c.name;

-- Only customers
SELECT * 
FROM staff s
RIGHT JOIN customer c
ON s.name = c.name;

-- Only those who are both staff and customer
SELECT * 
FROM staff s
JOIN customer c
ON s.name = c.name;

SELECT * 
FROM staff s
NATURAL JOIN customer c;

SELECT * 
FROM staff s
FULL OUTER JOIN customer c
USING (name)
ORDER BY s.id;

-- Everyone who is either a staff or a customer
SELECT * 
FROM staff s
FULL OUTER JOIN customer c
ON s.name = c.name;

-- Everyone who is either a staff or a customer but not both (everyone except John)
SELECT * 
FROM staff s
FULL OUTER JOIN customer c
ON s.name = c.name
WHERE s.name IS NULL OR c.name IS NULL;

-- UNION
-- Everyone who is either a staff or a customer (distinct records)
SELECT * FROM staff s
UNION
SELECT * FROM customer c
ORDER BY id;

-- INTERSECT
-- Everyone who is both a staff or a customer (distinct records)
SELECT *  FROM staff
INTERSECT
SELECT * FROM customer;

-- EXCEPT
-- Everyone who is just staff and not a customer (distinct records)
SELECT *  FROM staff
EXCEPT
SELECT * FROM customer;

-- EXCEPT
-- Everyone who is just customer and not staff (distinct records)
SELECT *  FROM customer
EXCEPT
SELECT * FROM staff;


-- Find names of passengers who have business class tickets with their booking ref
SELECT * FROM bookings;
SELECT * FROM tickets;
SELECT * FROM ticket_flights;

SELECT DISTINCT b.book_ref, b.book_date, t.ticket_no, t.passenger_id, t.passenger_name, tf.fare_conditions
FROM bookings b
LEFT OUTER JOIN tickets t
ON b.book_ref = t.book_ref
LEFT OUTER JOIN ticket_flights tf
ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
ORDER BY b.book_date; --93386 records

SELECT DISTINCT b.book_ref, b.book_date, t.ticket_no, t.passenger_id, t.passenger_name, tf.fare_conditions
FROM bookings b
JOIN tickets t
ON b.book_ref = t.book_ref
JOIN ticket_flights tf
ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
ORDER BY b.book_date; --93386 records

SELECT DISTINCT b.book_ref, b.book_date, t.ticket_no, t.passenger_id, t.passenger_name, tf.fare_conditions
FROM bookings b
RIGHT JOIN tickets t
ON b.book_ref = t.book_ref
LEFT JOIN ticket_flights tf
ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
ORDER BY b.book_date; --93386 records

-- USING
SELECT t.book_ref, t.ticket_no, t.passenger_name, b.total_amount
FROM tickets t
JOIN bookings b
USING (book_ref);

-- NATURAL JOIN (Don't need to use column name)
SELECT * 
FROM aircrafts
NATURAL JOIN seats;

-- 1. Who traveled from Moscow (SVO) to Novosibirsk (OVB) 
-- on seat 1A yesterday, and when was the ticket booked?
SELECT DISTINCT t.passenger_name, s.seat_no, f.departure_airport, f.arrival_airport 
FROM flights f
NATURAL JOIN ticket_flights tf
NATURAL JOIN tickets t
NATURAL JOIN aircrafts a
NATURAL JOIN seats s
WHERE f.departure_airport = 'SVO' 
  AND f.arrival_airport = 'OVB'
  AND s.seat_no = '1A'; -- 1003 records (911 DISTINCT)
  
--Solution (The day before yesterday” is counted from the public.now value, not from the current date)
SELECT t.passenger_name, b.book_date
FROM bookings b
NATURAL JOIN tickets t
-- ON t.book_ref = b.book_ref
NATURAL JOIN boarding_passes bp
-- ON bp.ticket_no = t.ticket_no
NATURAL JOIN flights f
-- ON f.flight_id = bp.flight_id
WHERE f.departure_airport = 'SVO' AND f.arrival_airport = 'OVB'
AND f.scheduled_departure::date = public.now()::date - INTERVAL '2 day'
AND bp.seat_no = '1A';

-- 2. Find the most disciplined passengers who checked in first for all their flights. 
-- Take into account only those passengers who took at least two flights ?
SELECT t.passenger_name, t.ticket_no
FROM tickets t
NATURAL JOIN boarding_passes bp
-- ON bp.ticket_no = t.ticket_no
GROUP BY t.passenger_name, t.ticket_no
HAVING MAX(bp.boarding_no) = 1 AND COUNT(*) > 1;

-- 3. Calculate the number of passengers and number of flights departing from 
-- one airport (SVO) during each hour on the indicated day 2017-08-02 ?
SELECT '2017-08-02' as date, 
		date_part ('hour', f.scheduled_departure) AS hourofday, 
		COUNT (ticket_no) passengers_cnt,
		COUNT (DISTINCT f.flight_id) flights_cnt
FROM flights f
NATURAL JOIN ticket_flights t 
-- ON f.flight_id = t.flight_id -- Using NATURAL, avoid this
WHERE f.departure_airport = 'SVO'
AND f.scheduled_departure >= '2017-08-02'::DATE
AND f.scheduled_departure <'2017-08-03'::DATE
GROUP BY 2;