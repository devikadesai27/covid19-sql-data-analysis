# 📊 COVID-19 SQL Data Analysis

This project explores global **COVID-19 cases, deaths, infection rates, and vaccination trends** using MySQL. The analysis includes data quality checks, exploratory data analysis, geographic comparisons, and vaccination tracking using SQL techniques such as joins, CTEs, temporary tables, window functions, and views.

## 🎯 Objective

Analyze global COVID-19 data to understand how cases, deaths, infection rates, and vaccination progress varied across countries, regions, and over time.

## 🛠️ Tools & Technologies

- MySQL
- MySQL Workbench
- SQL

## 📁 Project Structure

```text
├── data/
│   ├── CovidDeathsUpdated.csv        # COVID-19 cases and deaths dataset
│   └── CovidVaccinationUpdated.csv   # COVID-19 vaccination dataset
├── covid19_data_exploration.sql      # SQL data exploration and analysis
└── README.md                         # Project documentation
```

## 📈 Key Analysis

- Performed **data quality checks** for duplicate records, missing values, table structure, and date ranges.
- Compared **total cases, deaths, and population** to calculate death and infection percentages.
- Identified countries and regions with the **highest infection rates and death counts**.
- Analyzed **COVID-19 infection trends over time** across locations.
- Joined COVID-19 deaths and vaccination datasets to analyze **vaccination progress relative to population**.
- Calculated cumulative vaccinations using **SQL window functions**.
- Used **CTEs and temporary tables** to organize and analyze vaccination metrics.
- Created a **SQL view** to support reusable reporting and analysis.

## 📚 Skills Demonstrated

- SQL
- Data Exploration
- Data Quality Checks
- Exploratory Data Analysis (EDA)
- Aggregate Functions
- Joins
- Common Table Expressions (CTEs)
- Window Functions
- Temporary Tables
- Views
- Data Validation

---

## 🚀 How to Run

1. Open **MySQL Workbench**.
2. Import the COVID-19 deaths and vaccination datasets into MySQL.
3. Open `covid19_data_exploration.sql`.
4. Update the database/schema name if required.
5. Execute the queries section by section to explore the analysis.
