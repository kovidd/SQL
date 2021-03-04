-- Suggested testing environment: 
-- http://sqlite.online/

-- Question : An insurance company maintains records of sales made by its employees.
-- Each employee is assigned to a state. States are grouped under regions.
-- The following tables contain the data:

-- Example case create statement:
-- CREATE TABLE regions(
--   id INTEGER PRIMARY KEY,
--   name VARCHAR(50) NOT NULL
-- );

-- CREATE TABLE states(
--   id INTEGER PRIMARY KEY,
--   name VARCHAR(50) NOT NULL,
--   regionId INTEGER NOT NULL REFERENCES regions(id)
-- ); 

-- CREATE TABLE employees (
--   id INTEGER PRIMARY KEY,
--   name VARCHAR(50) NOT NULL, 
--   stateId INTEGER NOT NULL REFERENCES states(id)
-- );

-- CREATE TABLE sales (
--   id INTEGER PRIMARY KEY,
--   amount INTEGER NOT NULL,
--   employeeId INTEGER NOT NULL REFERENCES employees(id)
-- );

-- INSERT INTO regions(id, name) VALUES(1, 'North');
-- INSERT INTO regions(id, name) VALUES(2, 'South');
-- INSERT INTO regions(id, name) VALUES(3, 'East');
-- INSERT INTO regions(id, name) VALUES(4, 'West');
-- INSERT INTO regions(id, name) VALUES(5, 'Midwest');

-- INSERT INTO states(id, name, regionId) VALUES(1, 'Minnesota', 1);
-- INSERT INTO states(id, name, regionId) VALUES(2, 'Texas', 2);
-- INSERT INTO states(id, name, regionId) VALUES(3, 'California', 3);
-- INSERT INTO states(id, name, regionId) VALUES(4, 'Columbia', 4);
-- INSERT INTO states(id, name, regionId) VALUES(5, 'Indiana', 5);

-- INSERT INTO employees(id, name, stateId) VALUES(1, 'Jaden', 1);
-- INSERT INTO employees(id, name, stateId) VALUES(2, 'Abby', 1);
-- INSERT INTO employees(id, name, stateId) VALUES(3, 'Amaya', 2);
-- INSERT INTO employees(id, name, stateId) VALUES(4, 'Robert', 3);
-- INSERT INTO employees(id, name, stateId) VALUES(5, 'Tom', 4);
-- INSERT INTO employees(id, name, stateId) VALUES(6, 'William', 5);

-- INSERT INTO sales(id, amount, employeeId) VALUES(1, 2000, 1);
-- INSERT INTO sales(id, amount, employeeId) VALUES(2, 3000, 2);
-- INSERT INTO sales(id, amount, employeeId) VALUES(3, 4000, 3);
-- INSERT INTO sales(id, amount, employeeId) VALUES(4, 1200, 4);
-- INSERT INTO sales(id, amount, employeeId) VALUES(5, 2400, 5);

-- e.g. 'Minnesota' is the only state under the 'North' region. 
-- Total sales made by employees 'Jaden' and 'Abby' for the state of 'Minnesota' is 5000 (2000 + 3000)
-- Total employees in the state of 'Minnesota' is 2
-- Average sales per employee for the 'North' region = Total sales made for the region (5000) / Total number of employees (2) = 2500
-- Difference between the average sales of the region with the highest average sales ('South'), 
-- and the average sales per employee for the region ('North') = 4000 - 2500 = 1500.
-- Similarly, no sale has been made for the only state 'Indiana' under the region 'Midwest'.
-- So the average sales per employee for the region is 0.
-- And, the difference between the average sales of the region with the highest average sales ('South'), 
-- and the average sales per employee for the region ('Midwest') = 4000 - 0 = 4000.

-- Management requires a comparative region sales analysis report.
-- Write a query that returns:
-- 1. The region name.
-- 2. Average sales per employee for the region 
-- 	 (Average sales = Total sales made for the region / Number of employees in the region).
-- 3. The difference between the average sales of the region with the highest average sales,
-- 	  and the average sales per employee for the region (average sales to be calculated as explained above).
-- Employees can have multiple sales.
-- A region with no sales should be also returned.
-- Use 0 for average sales per employee for such a region when calculating the 2nd and the 3rd column.


-- Expected output (rows in any order):
-- name     average   difference
-- -----------------------------
-- North	2500	  1500             
-- South 	4000	  0
-- East		1200   	  2800
-- West		2400	  1600
-- Midwest  0         4000

SELECT  r.id AS region_id, r.name AS region_name,
		st.id AS state_id, st.name AS state_name,
		e.id AS emp_id, e.name AS emp_name,
		sa.id AS sale_id, sa.amount AS sale_amt
FROM
regions r LEFT JOIN
states st ON r.id = st.regionid LEFT JOIN
employees e ON st.id = e.stateid LEFT JOIN
sales sa ON e.id = sa.employeeid;

WITH emps AS
  (SELECT e.id, count(e.id) 
   FROM employees e 
   LEFT JOIN states s 
   ON e.stateID = s.id
   GROUP BY e.id)

SELECT * FROM emps;



