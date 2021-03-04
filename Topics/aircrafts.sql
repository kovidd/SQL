-- Select aircrafts with english models
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range FROM aircrafts LIMIT 10;

-- Select Airbus aircrafts with 200 in their model name
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range 
FROM aircrafts
WHERE model->>'en' LIKE '%Airbus%200%';

-- Select aircrafts with bus in their model name after 3 characters
SELECT aircraft_code, model->'en' AS eng_model, range as craft_range 
FROM aircrafts
WHERE model->>'en' LIKE '___bus%';

-- Extract no. of airplanes
Select * FROM aircrafts;
Select COUNT(*) FROM aircrafts;