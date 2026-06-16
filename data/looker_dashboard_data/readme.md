# 📊 Dashboard Data Pipeline (ETL)

The CSV files in this folder are the direct outputs of the SQL queries located in the `sql_analysis/` folder. 

### The Workflow:
1. **Extract:** Aggregated business metrics were queried using SQL (DuckDB).
2. **Transform (Google Sheets):** The raw CSV outputs were loaded into **Google Sheets**. Minor data formatting and specific calculated fields were added at the spreadsheet layer to optimize for BI ingestion.
3. **Load (Looker Studio):** The Google Sheets workbook acts as the direct, live data source for the Executive Looker Studio Dashboard.
