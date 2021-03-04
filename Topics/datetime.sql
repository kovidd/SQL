-- Date-Time
SELECT DATE '2001-09-28' + 7; -- → 2001-10-05
SELECT INTERVAL '1 hour' / 1.5; -- → 00:40:00 (1/1.5 = 0.66 → 0.66*60 = 40)
SELECT INTERVAL '1 hour' * 3.5;-- → 03:30:00
SELECT * FROM bookings;

-- Selecting dates with total_amount for that date
SELECT book_date, SUM(total_amount) as sales
FROM bookings
GROUP BY 1
ORDER BY 2
LIMIT 5;

-- Extracting the day for above (ignore year as all entries are from 2017)
SELECT EXTRACT('day' FROM book_date), EXTRACT('month' FROM book_date), SUM(total_amount) as sales
FROM bookings
GROUP BY 1, 2
ORDER BY 1;

-- Number of bookings in a day
SELECT book_date, COUNT(*) as numbookings
FROM bookings
GROUP BY book_date
ORDER BY numbookings DESC;

-- Number of bookings in a day DATE-TRUNC
SELECT DATE_TRUNC('day', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1
ORDER BY 1;

-- Number of bookings in a day DATE-TRUNC
SELECT DATE_TRUNC('day', book_date), DATE_TRUNC('month', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1, 2
ORDER BY 1;

-- Number of bookings in a week DATE-TRUNC
SELECT DATE_TRUNC('week', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1
ORDER BY 1;

-- Number of bookings in a day DATE-PART (for all months, 31 records)
SELECT DATE_PART('day', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1
ORDER BY 1;

-- Number of bookings in a day of that month DATE-PART (month specific, 56 records)
SELECT DATE_PART('day', book_date), DATE_PART('month', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1, 2
ORDER BY 1;

-- Find no. bookings on 25-06
SELECT DATE_PART('day', book_date) as day, DATE_PART('month', book_date) as month, COUNT(*) as numbookings
FROM bookings
GROUP BY 1, 2
HAVING DATE_PART('day', book_date) = 25 AND DATE_PART('month', book_date) = 6;

-- Number of bookings in the entire month DATE-PART (month specific, 3 records)
SELECT DATE_PART('month', book_date), COUNT(*) as numbookings
FROM bookings
GROUP BY 1
ORDER BY 1;

-- Select last date in the database
SELECT public.now();

-- Find bookings references for a given day
SELECT book_ref, book_date
FROM bookings
WHERE book_date = '13-08-2017'::DATE;

-- Current date
SELECT CURRENT_DATE;

-- Current time
SELECT CURRENT_TIME;

-- Current timestamp
SELECT CURRENT_TIMESTAMP;