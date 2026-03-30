
SELECT * FROM portproject.emission
LIMIT 500;

SELECT * FROM portproject.temp_change
LIMIT 500;

-- Emission by year
SELECT
  year,
  SUM(co2) AS total_co2,
  SUM(co2_including_luc) As total_co2_including_luc,
  SUM(total_ghg) AS total_ghg,
  SUM(total_ghg_excluding_lucf) AS total_ghg_excluding_lucf
FROM portproject.emission
WHERE iso_code != ''
GROUP BY year
ORDER BY  
  total_ghg DESC, 
  total_co2_including_luc DESC, 
  total_co2 DESC, 
  total_ghg_excluding_lucf DESC;

-- Temperature change from ghg by year
WITH temp_change AS (
  SELECT
    year,
    SUM(temperature_change_from_ghg) AS total_temperature_change_from_ghg
  FROM portproject.temp_change
  WHERE iso_code != ''
  GROUP BY year
)

SELECT
  year,
  total_temperature_change_from_ghg,
  total_temperature_change_from_ghg 
    - LAG(total_temperature_change_from_ghg, 1, 0) 
      OVER (ORDER BY year) AS yoy_change
FROM temp_change
ORDER BY yoy_change DESC;

-- Looking at temp change from ghg breakdown
SELECT country, year, 
  temperature_change_from_ch4/temperature_change_from_ghg * 100 AS ch4_pct,
  temperature_change_from_co2/temperature_change_from_ghg * 100  AS co2_pct,
  temperature_change_from_n2o/temperature_change_from_ghg * 100 AS n2o_pct
FROM portproject.temp_change
ORDER BY country, year;

-- COUNTRY BREAKDOWN 
-- Looking at total GHG emission per capita per year
SELECT 
  country,
  year,
  total_ghg/population AS total_ghg_per_capita,
  total_ghg_excluding_lucf/population  AS total_ghg_excluding_lucf_per_capita
FROM portproject.emission
WHERE 
  population > 0
  AND iso_code != ''
ORDER BY 
  total_ghg_excluding_lucf_per_capita DESC, 
  total_ghg_per_capita DESC;


-- Looking at country with highest cumulative ghg
SELECT 
  country,
  SUM(total_ghg) AS cumulative_ghg,
  SUM(total_ghg_excluding_lucf) AS cumulative_ghg_excluding_lucf
FROM portproject.emission
WHERE iso_code != ''
GROUP BY country
ORDER BY cumulative_ghg DESC, cumulative_ghg_excluding_lucf DESC;

-- Looking at country with highest cumulative ghg per capita 
SELECT 
  country,
  SUM(total_ghg)/SUM(population) AS cumulative_ghg_per_capita,
  SUM(total_ghg_excluding_lucf)/SUM(population) AS cumulative_ghg_excluding_lucf_per_capita
FROM portproject.emission
WHERE 
  population > 0
  AND total_ghg > 0
  AND total_ghg_excluding_lucf > 0
  AND iso_code != ''
GROUP BY country
ORDER BY 
  cumulative_ghg_per_capita DESC, 
  cumulative_ghg_excluding_lucf_per_capita DESC;


-- Looking at country with highest co2 emission
SELECT 
  country,
  SUM(co2) AS cumulative_co2,
  SUM(co2_including_luc) AS cumulative_co2_including_luc
FROM portproject.emission
WHERE iso_code != ''
GROUP BY country
ORDER BY 
  cumulative_co2 DESC, 
  cumulative_co2_including_luc DESC;

-- Looking at country with highest co2 emission per capita
SELECT 
  country,
  SUM(co2)/SUM(population) AS cumulative_co2_per_capita,
  SUM(co2_including_luc)/SUM(population) AS cumulative_co2_including_luc_per_capita
FROM portproject.emission
WHERE 
  population > 0
  AND co2 > 0
  AND co2_including_luc > 0
  AND iso_code != ''
GROUP BY country
ORDER BY 
  cumulative_co2_per_capita DESC, 
  cumulative_co2_including_luc_per_capita DESC;


-- Looking at Co2 % coming from land use
SELECT 
  country,
  SUM(land_use_change_co2)/SUM(co2_including_luc) AS land_use_pct
FROM portproject.emission
WHERE 
  land_use_change_co2 > 0 
  AND co2_including_luc > 0
  AND iso_code != ''
GROUP BY country
ORDER BY land_use_pct DESC;

-- Looking at ghg emission and temp change


WITH temp AS(
SELECT 
  t.year,
  SUM(total_ghg) AS current_year_ghg,
  SUM(temperature_change_from_ghg) AS cumulative_temperature_change_from_ghg
FROM portproject.emission e INNER JOIN portproject.temp_change t ON e.country = t.country AND e.year = t.year
WHERE t.iso_code != ''
GROUP BY t.year)
SELECT 
  year,
  current_year_ghg,
  SUM(current_year_ghg) OVER (ORDER BY year ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_ghg,
  cumulative_temperature_change_from_ghg,
  current_year_ghg/(cumulative_temperature_change_from_ghg - LAG(cumulative_temperature_change_from_ghg,1,0) OVER (ORDER BY year)) AS ghg_per_celcius_change
FROM temp
ORDER BY year ASC;






-- CREATE TABLE FOR visualizations
DROP TABLE IF EXISTS portproject.emission_clean;

CREATE TABLE portproject.emission_clean (
    country VARCHAR(100),
    year INT,
    population DOUBLE,
    gdp DOUBLE,
    total_ghg DOUBLE,
    total_ghg_excluding_lucf DOUBLE,
    total_ghg_excluding_lucf_per_capita DOUBLE,
    total_ghg_excluding_lucf_per_gdp DOUBLE
);

INSERT INTO portproject.emission_clean
SELECT 
    country,
    year,

    -- population
    CASE 
        WHEN population REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(population AS DECIMAL(20,2))
        ELSE NULL
    END AS population,

    -- gdp
    CASE 
        WHEN gdp REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(gdp AS DECIMAL(20,2))
        ELSE NULL
    END AS gdp,

    -- total_ghg
    CASE 
        WHEN total_ghg REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(total_ghg AS DECIMAL(20,2))
        ELSE NULL
    END AS total_ghg,

    -- total_ghg_excluding_lucf
    CASE 
        WHEN total_ghg_excluding_lucf REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(total_ghg_excluding_lucf AS DECIMAL(20,2))
        ELSE NULL
    END AS total_ghg_excluding_lucf,
    
	-- total_ghg_excluding_lucf per capita
    CASE 
        WHEN total_ghg_excluding_lucf REGEXP '^[0-9]+(\\.[0-9]+)?$' AND population REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(total_ghg_excluding_lucf AS DECIMAL(20,2))/CAST(population AS DECIMAL(20,2)) * 1000000
        ELSE NULL
    END AS total_ghg_excluding_lucf_per_capita,
	CASE 
        WHEN total_ghg_excluding_lucf REGEXP '^[0-9]+(\\.[0-9]+)?$' AND gdp REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(total_ghg_excluding_lucf AS DECIMAL(20,2))/CAST(gdp AS DECIMAL(20,2)) * 1000000
        ELSE NULL
    END AS total_ghg_excluding_lucf_per_gdp
FROM portproject.emission
WHERE 
  iso_code != ''
  AND year >= 1900;

SELECT * FROM portproject.emission_clean
WHERE country = 'United States';
 

-- second table 
DROP TABLE IF EXISTS portproject.temp_summary;

CREATE TABLE portproject.temp_summary AS
WITH temp AS (
    SELECT 
        t.year,
        SUM(t.temperature_change_from_ch4) AS ch4_temp_change,
        SUM(t.temperature_change_from_co2) AS co2_temp_change,
        SUM(t.temperature_change_from_ghg) AS ghg_temp_change,
        SUM(t.temperature_change_from_n2o) AS n2o_temp_change,
        SUM(e.total_ghg) AS ghg
    FROM portproject.emission e 
    INNER JOIN portproject.temp_change t 
        ON e.country = t.country 
       AND e.year = t.year
    WHERE 
        t.iso_code <> ''
        AND t.year >= 1900
    GROUP BY t.year
)
SELECT 
    *,
    ghg / (
        ghg_temp_change - LAG(ghg_temp_change, 1, 0) 
        OVER (ORDER BY year)
    ) AS ghg_per_celsius
FROM temp;

SELECT * FROM portproject.temp_summary
