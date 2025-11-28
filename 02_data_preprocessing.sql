-- PREPROCESSING DATA AND DEFINING VIEWS --

/* Create new table with formatted date column and without unit column  */

DROP TABLE IF EXISTS new_electricity_production;
CREATE TABLE new_electricity_production AS
   SELECT 
      country_name,
      CAST(printf('%04d%02d', SUBSTR(date, INSTR(date, '/') + 3, INSTR(date, '/') + 7), SUBSTR(date, 1, INSTR(date, '/') - 1)) AS INT) AS date_key,
      CAST(SUBSTR(date, INSTR(date, '/') + 3, INSTR(date, '/') + 7) AS INT) AS year,
      CAST(SUBSTR(date, 1, INSTR(date, '/') - 1) AS INT) AS month,
      parameter,
      product,
      value
   FROM global_production;


/* 
View of global flow of electricity 
*/

DROP VIEW IF EXISTS electricity_flow;
CREATE VIEW electricity_flow AS
   SELECT
      country_name,
      date_key,
      country_name || '_' || date_key AS country_date_key,
      year,
      month,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Net Electricity Production' THEN value ELSE 0 END) AS net_production,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Used for pumped storage' THEN value ELSE 0 END) AS used_for_pumped_storage,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Distribution Losses' THEN value ELSE 0 END) AS distribution_loss,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Final Consumption (Calculated)' THEN value ELSE 0 END) AS final_consumption,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Total Imports' THEN value ELSE 0 END) AS total_imports,
      SUM(CASE WHEN product = 'Electricity' AND parameter = 'Total Exports' THEN value ELSE 0 END) AS total_exports
   FROM new_electricity_production
   GROUP BY 1, 2;

/*
View of global electricity types
*/

DROP VIEW IF EXISTS electricity_types;
CREATE VIEW electricity_types AS
    SELECT 
        country_name, date_key, country_name || '_' || date_key AS country_date_key,
        ROUND(SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Electricity' THEN value ELSE 0 END), 3) AS total_production,
        ROUND(SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END)
            + SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Nuclear' THEN value ELSE 0 END), 3) AS total_renewables,
        ROUND(SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Combustible Fuels' THEN value ELSE 0 END) 
            - SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Combustible Renewables' THEN value ELSE 0 END), 3) AS total_non_renewable,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Not Specified' THEN value ELSE 0 END) AS not_specified,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Other Renewables' THEN value ELSE 0 END) AS other_renewables
   FROM new_electricity_production
   GROUP BY 1, 2;
SELECT * FROM electricity_types;

DROP VIEW IF EXISTS renewables_types;
CREATE VIEW renewables_types AS
    SELECT 
        country_name, date_key, country_name || '_' || date_key AS country_date_key,
        ROUND(SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END)
            + SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Nuclear' THEN value ELSE 0 END), 3) AS total_renewables,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Combustible Renewables' THEN value ELSE 0 END) AS combustible_renewables,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Hydro' THEN value ELSE 0 END) AS hydro,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Geothermal' THEN value ELSE 0 END) AS geothermal,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Solar' THEN value ELSE 0 END) AS solar,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Wind' THEN value ELSE 0 END) AS wind,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Other Renewables' THEN value ELSE 0 END) AS other_renewables,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Nuclear' THEN value ELSE 0 END) AS nuclear
    FROM new_electricity_production
   GROUP BY 1, 2;

DROP VIEW IF EXISTS non_renewables_types;
CREATE VIEW non_renewables_types AS
    SELECT 
        country_name, date_key, country_name || '_' || date_key AS country_date_key,
        ROUND(SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Total Combustible Fuels' THEN value ELSE 0 END) 
            - SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Combustible Renewables' THEN value ELSE 0 END), 3) AS total,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Oil and Petroleum Products' THEN value ELSE 0 END) AS oil_petroleum,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Coal, Peat and Manufactured Gases' THEN value ELSE 0 END) AS coal_peat_gases,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Natural Gas' THEN value ELSE 0 END) AS natural_gas,
        SUM(CASE WHEN parameter = 'Net Electricity Production' AND product = 'Other Combustible Non-Renewable' THEN value ELSE 0 END) AS other_non_renewabless
    FROM new_electricity_production
    GROUP BY 1, 2;