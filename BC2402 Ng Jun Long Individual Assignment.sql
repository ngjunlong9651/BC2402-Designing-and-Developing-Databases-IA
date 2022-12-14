-- BC2402 Individual Assignment
-- Created By: Ng Jun Long
-- Matriculation Number: U2110010D
-- Seminar Group: 5



-- Question 1
SELECT DISTINCT(category) 
FROM greenhouse_gas_inventory_data_data;

-- Question 2
SELECT SUM(value) FROM greenhouse_gas_inventory_data_data
WHERE country_or_area LIKE "European Union"
AND year BETWEEN "2010" AND "2014";

-- Question 3
SELECT year,category, value FROM greenhouse_gas_inventory_data_data
WHERE country_or_area LIKE "Australia"
AND value > 530000;

-- Question 4
SELECT greenhouse_gas_inventory_data_data.year AS Year, AVG(Extent) AS avg_extent, MAX(Extent) AS max_extent ,MIN(Extent) AS min_extent, SUM(value) AS total_emission
FROM seaice, greenhouse_gas_inventory_data_data
WHERE seaice.Year = greenhouse_gas_inventory_data_data.year
AND seaice.Year BETWEEN "2010" AND "2014"
GROUP BY greenhouse_gas_inventory_data_data.year;

-- Question 5
SELECT * FROM seaice;
SELECT * FROM globaltemperatures;
-- Creating a new column called FormatDate & 
-- Filling the new column with appropriate data
-- ALTER TABLE globaltemperatures
-- ADD FormatDate INT;

UPDATE globaltemperatures 
SET FormatDate = year(recordedDate)
WHERE FormatDate IS NULL;

-- There are 3192 rows same as original date values
SELECT COUNT(FormatDate)
FROM globaltemperatures;

SELECT FormatDate AS Year, AVG(Extent) AS avg_extent, MAX(CAST(Extent AS float)) AS max_extent, MIN(CAST(Extent AS float)) AS min_extent,
AVG(LandAverageTemperature) avgLandTemperature, MIN(CAST(LandAverageTemperature AS float)) minLandTemperature, MAX(CAST(LandAverageTemperature AS float)) maxLandTemperature
FROM globaltemperatures, seaice
WHERE globaltemperatures.FormatDate = seaice.Year
AND globaltemperatures.FormatDate >= 2010
GROUP BY FormatDate;



-- Question 6
SELECT * FROM greenhouse_gas_inventory_data_data;
SELECT * FROM temperaturechangebycountry;

SELECT temperaturechangebycountry.Year AS year, SUM(greenhouse_gas_inventory_data_data.value) AS total_emission,
AVG(temperaturechangebycountry.value) AS avgTempChange,
MIN(temperaturechangebycountry.value) AS minTempChange,
MAX(temperaturechangebycountry.value) AS avgTempChange
FROM greenhouse_gas_inventory_data_data, temperaturechangebycountry
WHERE greenhouse_gas_inventory_data_data.country_or_area = temperaturechangebycountry.Area
AND temperaturechangebycountry.Area = "Australia"
GROUP BY year
HAVING year BETWEEN 2010 AND 2014
ORDER BY year ASC;

-- Question 7
SELECT NAME, INVESTIGATOR, COUNT(WGMS_ID) AS surveyedAmt
FROM mass_balance_data
GROUP BY NAME, INVESTIGATOR
HAVING COUNT(WGMS_ID) > 11
ORDER BY NAME;

-- Question 8
-- How to identify ASEAN COUNTRY
-- Brunei and Laos have issues, still have not fixed
-- Above issue is fixed 23 Sept 12:19PM

-- ASEAN Is derived from all countries yearly change in average, not done yet
-- Solution 1 is to create a new row in original table by aggregating all values for that year
-- Solution 2 is to find a way to do it through a query


-- Singapore displayed some weird data, so decided to take a look
SELECT AVG(value) FROM temperaturechangebycountry
WHERE AREA = "Singapore"
AND Year > 2010
GROUP BY Year;

(
SELECT Area area, Year year, AVG(Value) avgValueChange
FROM temperaturechangebycountry
WHERE Area IN ("Cambodia","Indonesia","Singapore", "Malaysia", "%Lao%", "Myanmar", "Philippines","Thailand", "Viet Nam")
AND Year BETWEEN 2010 AND 2014
GROUP BY area, year

)
UNION
(
SELECT Area area, Year year, AVG(Value) avgValueChange
FROM temperaturechangebycountry
WHERE Area LIKE ("%Laos%")
OR Area LIKE ("%Brunei%")
AND Year BETWEEN 2010 AND 2014
GROUP BY area, year
)
ORDER BY year, area;




-- Question 9
-- This gives me the average for the country in year based on category 2000
SELECT country_or_area, category, year, SUM(value) AS cat_yearValue
FROM greenhouse_gas_inventory_data_data AS A
GROUP BY country_or_area, category;

-- I just want to know the total for the country and category
SELECT country_or_area, category, AVG(value)
FROM greenhouse_gas_inventory_data_data
GROUP BY country_or_area, category;


-- Unable to find a way to do it with queries, think have to create a view to store the previous two queries as a variable and create a merged view
CREATE VIEW cat_avg_view
AS
SELECT country_or_area, category, AVG(value) AS cat_overallAvgValue
FROM greenhouse_gas_inventory_data_data
GROUP BY country_or_area, category;

CREATE VIEW cat_yearly_view
AS
SELECT country_or_area, category, year, AVG(value) AS cat_yearValue
FROM greenhouse_gas_inventory_data_data
GROUP BY country_or_area, category, year;

-- Merging both views
SELECT A1.country_or_area, A1.category, cat_overallAvgValue, year, cat_yearValue
FROM cat_avg_view AS A1, cat_yearly_view AS A2
WHERE A1.category = A2.category
AND A1.country_or_area = A2.country_or_area
AND A2.cat_yearValue < A1.cat_overallAvgValue
ORDER BY A1.category, A1.country_or_area, year DESC;


-- Question 10
CREATE VIEW View1
AS 
SELECT A1.Year, A1.Domain, AVG(Value) avgValue, AVG(Extent) avgExtent
FROM temperaturechangebycountry A1 ,  seaice B1
WHERE A1.year = B1.Year
AND A1.Year BETWEEN 2008 AND 2017
AND Area LIKE "United States of America"
GROUP BY Year, Domain
ORDER BY Year;

-- Removing the last few digits
-- UPDATE elevation_change_data
-- SET SURVEY_DATE=SUBSTRING(SURVEY_DATE,1, length(SURVEY_DATE)-4);
--
CREATE VIEW View2
AS
SELECT SURVEY_DATE year , INVESTIGATOR, AVG(elevation_change_unc) avgElevationChange
FROM elevation_change_data D
WHERE Investigator LIKE "Martina%"
GROUP BY year, Investigator 
ORDER BY year;


-- Joining both view1 and view2
SELECT View1.`year`, avgV. alue, avgExtent, avgElevationChange
FROM View1, View2
WHERE View1.`year` = View2.`year`;











































