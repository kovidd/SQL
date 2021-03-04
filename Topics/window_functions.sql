-- Window functions --

-- row_number () → bigint
-- Returns the number of the current row within its partition, counting from 1.

-- rank () → bigint
-- Returns the rank of the current row, with gaps; that is, the row_number of the first row in its peer group.

-- dense_rank () → bigint
-- Returns the rank of the current row, without gaps; this function effectively counts peer groups.

-- percent_rank () → double precision
-- Returns the relative rank of the current row, that is (rank - 1) / (total partition rows - 1). The value thus ranges from 0 to 1 inclusive.

-- cume_dist () → double precision
-- Returns the cumulative distribution, that is (number of partition rows preceding or peers with current row) / (total partition rows). The value thus ranges from 1/N to 1.

-- ntile ( num_buckets integer ) → integer
-- Returns an integer ranging from 1 to the argument value, dividing the partition as equally as possible.

-- lag ( value anyelement [, offset integer [, default anyelement ]] ) → anyelement
-- Returns value evaluated at the row that is offset rows before the current row within the partition; if there is no such row, instead returns default (which must be of the same type as value). Both offset and default are evaluated with respect to the current row. If omitted, offset defaults to 1 and default to NULL.

-- lead ( value anyelement [, offset integer [, default anyelement ]] ) → anyelement
-- Returns value evaluated at the row that is offset rows after the current row within the partition; if there is no such row, instead returns default (which must be of the same type as value). Both offset and default are evaluated with respect to the current row. If omitted, offset defaults to 1 and default to NULL.

-- first_value ( value anyelement ) → anyelement
-- Returns value evaluated at the row that is the first row of the window frame.

-- last_value ( value anyelement ) → anyelement
-- Returns value evaluated at the row that is the last row of the window frame.

-- nth_value ( value anyelement, n integer ) → anyelement
-- Returns value evaluated at the row that is the n'th row of the window frame (counting from 1); returns NULL if there is no such row.




---------------------------------------------------------------------------------

--
SELECT s.seat_no, s.fare_conditions, a.model->>'en' AS model, AVG(a.range) as avg_range
FROM seats s
JOIN aircrafts a
USING (aircraft_code)
GROUP BY 1,2,3;

-- Now we want to group the avg_range without affecting the 1st 3 columns, use Window OVER func
SELECT s.seat_no, s.fare_conditions, a.model->>'en' AS model, 
AVG(a.range) OVER (PARTITION BY model) AS avg_range
FROM seats s
JOIN aircrafts a
USING (aircraft_code)
GROUP BY 1, 2, model, range;

-- RANK
SELECT s.seat_no, s.fare_conditions, a.model->>'en' AS model, range,
RANK() OVER (PARTITION BY s.seat_no ORDER BY a.range DESC) AS range_rank
FROM seats s
JOIN aircrafts a
USING (aircraft_code)
ORDER BY range_rank;


-- NTILE
SELECT s.seat_no, s.fare_conditions, a.model->>'en' AS model, range,
NTILE (5) OVER (PARTITION BY s.seat_no ORDER BY a.range DESC) AS range_rank
FROM seats s
JOIN aircrafts a
USING (aircraft_code)
ORDER BY range_rank;

-- LEAD
-- Sum of sales for 3 months
SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS total_sales
FROM bookings
GROUP BY month
ORDER BY month;

-- Using lead, find the sum of this month and the next month, for comparison
WITH cte AS (SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS total_sales
			 FROM bookings
			 GROUP BY month
			 ORDER BY month
			)

SELECT month, total_sales, LEAD (total_sales, 1) OVER (ORDER BY month) AS next_month_total_sales
FROM cte;

-- Find the sum of this month and the next month, for comparison and also the Variance
WITH cte AS (SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS total_sales
			 FROM bookings
			 GROUP BY month
			 ORDER BY month
			),
	 cte2 AS (SELECT month, 
			         total_sales, 
			         LEAD (total_sales, 1) OVER (ORDER BY month) AS next_month_total_sales
			  		 FROM cte
	 		)

SELECT month, total_sales, next_month_total_sales, (next_month_total_sales - total_sales) AS variance
FROM cte2;

-- LAG (opposite to LEAD)
WITH cte AS (SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS total_sales
			 FROM bookings
			 GROUP BY month
			 ORDER BY month
			)

SELECT month, total_sales, LAG (total_sales, 1) OVER (ORDER BY month) AS previous_month_total_sales
FROM cte;

-- Find the sum of this month and the previous month, for comparison and also the Variance
WITH cte AS (SELECT DATE_PART('month', book_date) AS month, SUM(total_amount) AS total_sales
			 FROM bookings
			 GROUP BY month
			 ORDER BY month
			),
	 cte2 AS (SELECT month, 
			         total_sales, 
			         LAG (total_sales, 1) OVER (ORDER BY month) AS previous_month_total_sales
			  		 FROM cte
	 		)

SELECT month, total_sales, previous_month_total_sales, (total_sales - previous_month_total_sales) AS variance
FROM cte2;

