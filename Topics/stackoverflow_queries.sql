-- Question on stackoverflow: 
-- https://stackoverflow.com/questions/66220713/update-values-on-multiple-rows-where-a-condition-is-fulfilled-sql
--		I want to change the last character to 0 in zip_code column of the rows with condition :
--      SELECT * FROM city WHERE MOD(CAST(zipcode AS int), 10) <> 0;

-- CREATE TABLE IF NOT EXISTS city (
-- 	id SERIAL PRIMARY KEY,
-- 	zipcode INT NOT NULL,
-- 	ville TEXT NOT NULL
-- );

-- TRUNCATE city;
-- INSERT INTO city (id, zipcode, ville)
-- VALUES (1, 1234, 'Paris'),
-- 	   (3, 5678, 'Egypt'),
-- 	   (5, 9876, 'Delhi');

SELECT * FROM city WHERE MOD(CAST(zipcode AS int), 10) <> 0;

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

-- Using REGEX
UPDATE city
SET zip_code = REGEXP_REPLACE(zip_code, '.$', '0')
WHERE zip_code NOT LIKE '%0';
SELECT * FROM city;