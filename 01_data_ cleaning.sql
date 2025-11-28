-- QUALITY CHECKS --

/*
1. Check whether there is duplicates in (country_name, date, parameter, product).
*/

SELECT country_name, date, parameter, product, COUNT(*)
FROM global_production
GROUP BY 1, 2, 3, 4
HAVING COUNT(*) > 1;

/*
2. Check whether the unit column is not GWh anywhere. If there is none, we can drop it in data modeling.
*/

SELECT *
FROM global_production
WHERE unit <> 'GWh';

/*
3. Check for possible double-counting of combustible renewables in electricity types.
*/

WITH temp_table AS (
   SELECT 
      country_name, 
      date, 
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Electricity' THEN value ELSE 0 END) AS total_production,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END) AS renewables,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Combustible Fuels' THEN value ELSE 0 END) AS combustible,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Combustible Renewables' THEN value ELSE 0 END) AS combustible_renewables,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Nuclear' THEN value ELSE 0 END) AS nuclear,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Other Renewables' THEN value ELSE 0 END) AS other_renewables,
      SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Not Specified' THEN value ELSE 0 END) AS not_specified
   FROM global_production
   GROUP BY country_name, date
) 
SELECT *
FROM temp_table
WHERE ROUND((renewables + combustible + nuclear + not_specified - combustible_renewables) - total_production, 0) > 0.01 * total_production;

/*
4. Check for outliers or data-entry errors.
*/

SELECT *
FROM global_production
WHERE parameter = 'Final Consumption (Calculated)' AND value = 0;

/*
5. Check for NULL value.
*/

SELECT *
FROM global_production
WHERE country_name IS NULL
OR date IS NULL
OR parameter IS NULL
OR product IS NULL
OR value IS NULL;