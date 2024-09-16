## Project Overview
This project focuses on the data preparation, cleaning, and analysis of two datasets: ad_data and marketing_data. By analyzing customer demographics, advertising effectiveness, and product category performance across different segments, the goal is to provide actionable insights for the Marketing Department to optimize 2Market’s marketing strategies, efficiently allocate the budget, and identify sales growth opportunities.

## Tools and Techniques
This project demonstrates the power of combining:

Excel: For basic data cleaning and exploration of medium-sized datasets.
PostgreSQL: For database creation, manipulation, and complex analysis. The data was processed in two key stages:
Staging Level: Data was cleaned and structured in the staging tables for further analysis.
Reporting Level: Final, cleaned datasets were prepared for advanced reporting and extraction into Tableau.Tableau: Employed for its advanced visualization features, allowing for a more comprehensive and intuitive analysis of the data.
To explore the dashboards, visit my profile on Tableau Public: https://public.tableau.com/app/profile/andrea.rossi2342/vizzes

## Data Processing Workflow 
Stage 1 - Data Cleaning and Initial Exploration:
Bulk data cleaning and preliminary exploration were performed using Excel. This method was chosen for its simplicity and effectiveness when dealing with medium to small-sized datasets. Excel enabled quick detection and correction of issues like missing data, duplicates, and inconsistent formatting, preparing the data for deeper analysis.

Stage 2 - Advanced Analysis with PostgreSQL:
After the initial cleaning, the datasets were migrated into PostgreSQL for more complex data manipulation and descriptive analysis. A dedicated database, named 2M_Analysis, was created to house the cleaned data in two tables representing the marketing and advertising datasets. PostgreSQL was used to run queries to gain insights into purchasing behavior, and social media advertising effectiveness.
