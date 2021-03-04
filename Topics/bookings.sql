-- Booking
-- SELECT * FROM bookings;

-- Select bookings withing date range May and July 2017
-- SELECT * 
-- FROM bookings
-- WHERE book_date BETWEEN TO_DATE ('05/01/2017 09:00:00 AM', 'mm/dd/yyyy hh:mi:ss AM')
--                     AND TO_DATE ('07/31/2017 10:00:00 AM', 'mm/dd/yyyy hh:mi:ss AM')
-- ORDER BY book_date;
 
-- Easier way
-- SELECT * 
-- FROM bookings
-- WHERE book_date BETWEEN '2017/05/01 09:00:00 AM' AND '2017/07/31 10:00:00 AM'
-- ORDER BY book_date;

-- Also, TO_CHAR can be used to convert timestamp into string
-- Even easier
-- SELECT * 
-- FROM bookings
-- WHERE book_date BETWEEN '2017/05/01%' AND '2017/07/31%'
-- ORDER BY book_date;

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