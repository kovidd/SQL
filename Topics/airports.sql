-- SELECT * FROM airports;

-- Select airports with english models (json values)
-- SELECT airport_code, airport_name->'en', city->'en', coordinates, timezone
-- FROM airports LIMIT 10;

-- Select Moscow city airports
-- -> gives a string output, ->> gives a text output
-- SELECT airport_code, airport_name->'en', city->'en', coordinates, timezone
-- FROM airports
-- WHERE city->>'en' = 'Moscow';

-- Select Moscow city airports
-- SELECT airport_code, airport_name->>'en', city->>'en', coordinates, timezone
-- FROM airports
-- WHERE city->>'en' = 'Moscow';

-- Select airports in Asia timezone
SELECT airport_code, airport_name->>'en', city->>'en', coordinates, timezone
FROM airports
WHERE timezone LIKE '%Asia%';