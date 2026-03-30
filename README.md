# ghg_emission_sql_tableau
# Greenhouse Gas Emissions & Temperature Change Analysis

## Overview  
This project analyzes global greenhouse gas (GHG) emissions and their relationship with temperature change over time. The workflow combines SQL-based data exploration with interactive visualization in Tableau using a MySQL data connection.

## Data Sources  
The analysis uses two main datasets:  
- **Emission data**: country-level GHG, CO₂, GDP, and population  
- **Temperature data**: temperature change attributed to CO₂, CH₄, and N₂O  
- Source: Our World in Data – https://ourworldindata.org/co2-and-greenhouse-gas-emissions  

## Methodology  

### 1. Data Exploration (SQL)  
An example of data processing was performed in MySQL:  
- Aggregated emissions by year and country  
- Calculated per capita and per GDP metrics  
- Analyzed cumulative emissions and year-over-year changes  
- Joined emission and temperature datasets  
- Built derived metrics (e.g., GHG per capita, GHG per GDP)
SQL techniques include: Common Table Expressions (CTEs), Window Functions, Calculated Columns, Filtering, Aggregations, Joins, Type Casting, and Conditional Logics

**Data cleaning steps:**  
- Cast fields into numeric formats  
- Filtered missing or inconsistent records (taking only data from 1900 onwards)

**Final tables created:**  
- `emission_clean`: standardized emissions, GDP, population, and derived metrics  
- `temp_summary`: aggregated temperature change and GHG relationships  

### 2. Data Visualization (Tableau)  
Tableau is connected directly to MySQL to build an interactive dashboard.

## Key Insights  
- Emissions are concentrated in large economies, but per capita emissions vary widely  
- CO₂ is the primary driver of temperature change, followed by Ch4 and N2o  
- GHG increase and temperature change possess a positive linear relationship, but the intensity varies
- Annual GHG emissions and cumulative temperature change show a consistent upward trend over time, with minimal evidence of reversal.

## Tools & Technologies  
- **MySQL** (data cleaning & analysis)  
- **Tableau** (visualization)  

## Limitations  
- Data quality varies by country and year  
