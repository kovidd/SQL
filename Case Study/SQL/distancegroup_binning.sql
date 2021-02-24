-- CREATE TABLE DIS 
-- 	(
-- 		mile TEXT 
-- 	);

-- INSERT INTO DIS (mile)
-- VALUES ('0 miles'),
-- 	   ('10 miles'),
-- 	   ('99 miles'),
-- 	   ('100 miles'),
-- 	   ('101 miles'),
-- 	   ('879 miles'),
-- 	   ('999 miles'),
-- 	   ('1001 miles'),
-- 	   ('2009 miles'),
-- 	   ('4569 miles'),
-- 	   ('2356 miles'),
-- 	   ('1234 miles'),
-- 	   ('1201 miles'),
-- 	   ('1300 miles'),
-- 	   ('1200 miles'),
-- 	   ('1009 miles'),
-- 	   ('1100 miles'),
-- 	   ('3300 miles'),
-- 	   ('3000 miles'),
-- 	   ('9000 miles'),
-- 	   ('9999 miles');
	   
SELECT CAST(SUBSTRING(mile FROM ('[0-9]+')) AS INT),
	   CASE WHEN CAST(SUBSTRING(mile FROM ('[0-9]+')) AS INT) <= 100 THEN
	   '0-100 miles'
	   WHEN CAST(SUBSTRING(mile FROM ('[0-9]+')) AS INT) >= 10001 THEN
	   '10000+ miles'
	   WHEN LENGTH(SUBSTRING(mile FROM ('[0-9]+'))) = 3 THEN
	   CASE 
	   	   WHEN SUBSTRING(SUBSTRING(mile FROM ('[0-9]+')), 2, 2) LIKE '_0' THEN
		   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{1}')) AS INT) - 1) AS TEXT) || '01-' ||
		   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{1}')) AS INT)) AS TEXT) || '00 miles'
		   ELSE
		   SUBSTRING(mile FROM ('[0-9]{1}')) || '01-' ||
		   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{1}')) AS INT)+1) AS TEXT) || '00 miles'
	   END
	   
	   WHEN SUBSTRING(SUBSTRING(mile FROM ('[0-9]+')), 2, 3) LIKE '_00' THEN
	   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{2}')) AS INT) - 1) AS TEXT) || '01-' ||
	   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{2}')) AS INT)) AS TEXT) || '00 miles'
	   ELSE
	   SUBSTRING(mile FROM ('[0-9]{2}')) || '01-' ||
	   CAST((CAST(SUBSTRING(mile FROM ('[0-9]{2}')) AS INT)+1) AS TEXT) || '00 miles'
	   
	   END
	   AS DISTANCEGROUP
FROM DIS;

-- Final Solution
-- Binning of miles to DISTANCEGROUP
SELECT DISTINCT(distance), CAST(SUBSTRING(DISTANCE FROM ('[0-9]+')) AS INT) ,
	CASE WHEN CAST(SUBSTRING(DISTANCE FROM ('[0-9]+')) AS INT) <= 100 THEN '0-100 miles'
	WHEN CAST(SUBSTRING(DISTANCE FROM ('[0-9]+')) AS INT) >= 10001 THEN '10000+ miles'
	WHEN LENGTH(SUBSTRING(DISTANCE FROM ('[0-9]+'))) = 3 THEN
	CASE 
		WHEN SUBSTRING(SUBSTRING(DISTANCE FROM ('[0-9]+')), 2, 2) LIKE '00' THEN
		CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{1}')) AS INT) - 1) AS TEXT) || '01-' ||
		CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{1}')) AS INT)) AS TEXT) || '00 miles'
		ELSE
		SUBSTRING(DISTANCE FROM ('[0-9]{1}')) || '01-' ||
		CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{1}')) AS INT)+1) AS TEXT) || '00 miles'
	END
	
	WHEN SUBSTRING(SUBSTRING(DISTANCE FROM ('[0-9]+')), 2, 3) LIKE '_00' THEN
	CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{2}')) AS INT) - 1) AS TEXT) || '01-' ||
	CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{2}')) AS INT)) AS TEXT) || '00 miles'
	
	ELSE
	SUBSTRING(DISTANCE FROM ('[0-9]{2}')) || '01-' ||
	CAST((CAST(SUBSTRING(DISTANCE FROM ('[0-9]{2}')) AS INT)+1) AS TEXT) || '00 miles'
	
	END
	AS DISTANCEGROUP
FROM FLIGHTS
LIMIT 100;

SELECT MAX(CAST(SUBSTRING(distance FROM ('[0-9]+')) AS INT)) FROM flights; -- 4983 miles
SELECT MIN(CAST(SUBSTRING(distance FROM ('[0-9]+')) AS INT)) FROM flights; -- 11 miles