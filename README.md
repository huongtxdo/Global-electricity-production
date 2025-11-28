# Global-electricity-production

** OBJECTIVES **

1. Get an overview of the global energy production and trend:
    - What are the sources of electricity?
    - What are the global trends in term of producing electricity using renewable sources?
2. Understanding the energy logistics of each country
    - What are the sources of electricity?
    - 

** DATA CLEANING **

1. Check whether there is duplicates in (country_name, date, parameter, product).
    - We found none so it safe to say that there is no duplicates.
2. Check whether the unit column is not GWh anywhere. If there is none, we can drop it in data modeling.
    - All entries are in GWh.
3. Check for possible double-counting of combustible renewables:
    - We check it by calculating the sum of renewables, combustible, nuclear and not specified, then subtract combustible renewables from it and compare it with the original total production from the dataset.
    - The result should be less than 1% of the original total production (due to entry or rounding errors).
    - The query returns empty, so combustible Renewables’ are included in both ‘Total Combustible Fuels’ and ‘Total Renewables’. 
    - Therefore,'Combustible Renewables' will be reclassified to be exclusively under ‘Total Renewables’.
4. Check for outliers or data-entry errors.
    - Check whether there is any 0 value entry for 'Final Consumption (Calculated)' parameter.
5. Check for NULL value.
    - All NULL-value is in the 'Remarks' parameter with description 'Data is estimated for this month'.
    - Because we have checked for double-counting, we can safely remove all NULL values in data modeling.

    
** DATA PREPROCESSING **

1. Reformat the date column (current type: TEXT) by creating new month and year columns (type: INT), and a date_key column yyyymm for easier analysis. 
2. Create wide views (global electricity flow, global electricity production, including renewable and non-renewable sources) for convenient data analysis with SQL.
3. The datasets are loaded into Power BI via Python script
