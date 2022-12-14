-- BC2402 Individual Assignment
-- Created By: Ng Jun Long
-- Matriculation Number: U2110010D
-- Seminar Group: 5



-- Question 1
-- Data Exploration 
SELECT * FROM greenhouse_gas_inventory_data_data;
SELECT * FROM greenhouse_gas_inventory_data_data
WHERE VALUE IS NULL;
-- Data seems intact and  no null values detected

-- Select distinct catefory
SELECT DISTINCT(category) 
FROM greenhouse_gas_inventory_data_data;

-- Question 2
-- Double checking for null values
SELECT value FROM greenhouse_gas_inventory_data_data
WHERE value IS NULL;
-- No null values detected


-- Running select statement
SELECT SUM(value) FROM greenhouse_gas_inventory_data_data
WHERE country_or_area LIKE "European Union"
AND year BETWEEN "2010" AND "2014";

-- Question 3
SELECT year,category, value FROM greenhouse_gas_inventory_data_data
WHERE country_or_area LIKE "Australia"
AND value > 530000;

-- Question 4
-- Need to check for NULL or values that are in target tables
SELECT *
FROM greenhouse_gas_inventory_data_data
WHERE value IS NULL OR value = 0;


SELECT seaice.Year,AVG(CAST(seaice.Extent AS float)) AS avg_extent,MAX(CAST(seaice.Extent AS float)) AS max_extent, MIN(CAST(seaice.Extent AS float)) AS min_extent, total_emission
FROM seaice,
    (SELECT year,SUM(CAST(greenhouse_gas_inventory_data_data.value AS float)) AS total_emission
    FROM greenhouse_gas_inventory_data_data
    WHERE year BETWEEN 2010 AND 2014
    GROUP BY year) AS yearly_emission
WHERE
    seaice.year = yearly_emission.year
    AND seaice.year BETWEEN 2010 AND 2014
GROUP BY year;


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

-- Need to cast temperature to float.
SELECT FormatDate AS Year, AVG(Extent) AS avg_extent, MAX(CAST(Extent AS float)) AS max_extent, MIN(CAST(Extent AS float)) AS min_extent,
AVG(LandAverageTemperature) avgLandTemperature, MIN(CAST(LandAverageTemperature AS float)) minLandTemperature, MAX(CAST(LandAverageTemperature AS float)) maxLandTemperature
FROM globaltemperatures, seaice
WHERE globaltemperatures.FormatDate = seaice.Year
AND globaltemperatures.FormatDate BETWEEN 2010 AND 2014
GROUP BY FormatDate;



-- Question 6
SELECT * FROM greenhouse_gas_inventory_data_data;

SELECT * FROM temperaturechangebycountry
WHERE Value = 0 AND Area = "Australia";
-- Above is to check for null values 
SELECT * FROM temperaturechangebycountry;

-- Need to cast temperature to float.
SELECT AUS_emission.year, AUS_emission.total_emission AS total_emission ,AUS_temperature.avgTemperatureChange AS avgTemperatureChange,
CAST(AUS_temperature.minTemperatureChange AS float) AS minTempChange, AUS_temperature.maxTemperatureChange AS maxTempChange
FROM (SELECT year, SUM(value) AS total_emission
    FROM greenhouse_gas_inventory_data_data
    WHERE Year BETWEEN 2010 AND 2014
	AND country_or_area = 'Australia'
    GROUP BY year) AS AUS_emission,
    (SELECT Year, AVG(CAST(temperaturechangebycountry.value AS float)) AS avgTemperatureChange, MIN(CAST(ABS(temperaturechangebycountry.value) AS float)) AS minTemperatureChange, MAX(CAST(ABS(temperaturechangebycountry.value) AS float)) AS maxTemperatureChange
    FROM temperaturechangebycountry
    -- Decided to use ABS changes to show the magnitude of change rather than the effect of a positive or negative temperature. 
    WHERE Year BETWEEN 2010 AND 2014 AND Area = 'Australia'
    GROUP BY 
    year) AS AUS_temperature
WHERE AUS_emission.year = AUS_temperature.Year
GROUP BY AUS_emission.year;

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


-- When updating, need to bypass error code 1175, I did this by entering the following code:
SET SQL_SAFE_UPDATES = 0; 

UPDATE temperaturechangebycountry
SET Value = NULL
WHERE Value = ""; #There are blank values within the SQL table, hence, need to convert it to null so that SQL can do proper aggregation
-- Failure to do this will constitue to SQL adding empty values which affects the calculation. Thus rendering the results inaccurate
SET SQL_SAFE_UPDATES = 1; #After editing the table, I will return SQL to "safe update mode" to prevent incidental tempering of data

-- Singapore displayed some weird data, so decided to take a look
SELECT AVG(value) FROM temperaturechangebycountry
WHERE AREA = "Singapore"
AND Year > 2010
GROUP BY Year;
-- Singapore does not have any values

SELECT * FROM temperaturechangebycountry
WHERE Value = 0 AND Area In ("Brunei Darussalam", "Cambodia", "Indonesia", "Lao People's Democratic Republic",
"Malaysia", "Myanmar", "Philippines", "Singapore", "Thailand", "Viet Nam");
#Check for NULL or empty values in all ASEAN countries



(SELECT Area, Year as year, AVG(Value) AS avgValueChange
FROM temperaturechangebycountry
WHERE (Year BETWEEN 2010 AND 2014) 
AND Area In ("Brunei Darussalam", "Cambodia", "Indonesia", "Lao People's Democratic Republic", "Malaysia", "Myanmar",
"Philippines", "Singapore", "Thailand", "Viet Nam") -- Had to spell out Brunei Darussalam and Lao people... This is to avoid future conflicts if the list of countries are expanded. Originally wanted to apply a "Brunei%" style
GROUP BY Year, Area)

UNION #Joins with the new table that has just been creatd. This allows me to preserve the information and data from both the above and below table

(SELECT "ASEAN" AS Area, Year as year, AVG(Value) AS avgValueChange
FROM temperaturechangebycountry
WHERE (Year BETWEEN 2010 AND 2014) AND
Area In ("Brunei Darussalam", "Cambodia", "Indonesia", "Lao People's Democratic Republic", "Malaysia", "Myanmar",
"Philippines", "Singapore", "Thailand", "Viet Nam") 
GROUP BY Year) #Creating a new row called ASEAN, that contains all the asean countries 
ORDER BY Year, Area;

-- Question 9
-- This gives me the average for the country in year based on category 2000
SELECT country_or_area, category, year, SUM(value) AS cat_yearValue
FROM greenhouse_gas_inventory_data_data AS A
GROUP BY country_or_area, year, category;

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
SELECT * FROM elevation_change_data;
SELECT survey_date,(elevation_change_unc)
FROM elevation_change_data
WHERE elevation_change_unc = 0;
-- There are certain years where elevation change = 0 or user input error
-- Assuming that the year has 0 elevation change.

SELECT survey_date,(elevation_change_unc)
FROM elevation_change_data
WHERE elevation_change_unc < 0;
-- These are the years where elevation change < 0 indicating elevation went downwards?

CREATE VIEW View2
AS
SELECT SURVEY_DATE year , INVESTIGATOR, AVG(elevation_change_unc) avgElevationChange
FROM elevation_change_data 
WHERE Investigator LIKE "Martina%"
GROUP BY year, Investigator 
ORDER BY year;


-- Joining both view1 and view2
SELECT View1.`year`, avgValue, avgExtent, (avgElevationChange)
FROM View1, View2
WHERE View1.`year` = View2.`year`;











































