 /* =========================================================
    DATA EXPLORATION AND QUALITY CHECKS
   ========================================================= */
# Preview death data
select *
from portfolio_project.coviddeathsupdated
limit 10;

# Preview vaccination data
SELECT *
FROM portfolio_project.covidvaccinationupdated
LIMIT 10;

# check table structure for both the tables
DESCRIBE portfolio_project.coviddeathsupdated;

DESCRIBE portfolio_project.covidvaccinationupdated;

# total row counts
SELECT COUNT(*) AS total_death_rows
FROM portfolio_project.coviddeathsupdated;

SELECT COUNT(*) AS total_vaccination_rows
FROM portfolio_project.covidvaccinationupdated;

# Check duplicates in both tables
SELECT
    location,
    `date`,
    COUNT(*) AS duplicate_count
FROM portfolio_project.coviddeathsupdated
GROUP BY location, `date`
HAVING COUNT(*) > 1;

SELECT
    location,
    `date`,
    COUNT(*) AS duplicate_count
FROM portfolio_project.covidvaccinationupdated
GROUP BY location, `date`
HAVING COUNT(*) > 1;

# Check null values in important columns in both tables
SELECT
    COUNT(*) AS TotalRows,
    SUM(continent IS NULL) AS Continent_Nulls,
    SUM(location IS NULL) AS Location_Nulls,
    SUM(`date` IS NULL) AS Date_Nulls,
    SUM(population IS NULL) AS Population_Nulls,
    SUM(total_cases IS NULL) AS TotalCases_Nulls,
    SUM(new_cases IS NULL) AS NewCases_Nulls,
    SUM(total_deaths IS NULL) AS TotalDeaths_Nulls,
    SUM(new_deaths IS NULL) AS NewDeaths_Nulls
FROM portfolio_project.coviddeathsupdated;

SELECT
    COUNT(*) AS TotalRows,
    SUM(continent IS NULL) AS Continent_Nulls,
    SUM(location IS NULL) AS Location_Nulls,
    SUM(`date` IS NULL) AS Date_Nulls,
    SUM(population IS NULL) AS Population_Nulls,
    SUM(new_vaccinations IS NULL) AS NewVaccinations_Nulls,
    SUM(total_vaccinations IS NULL) AS TotalVaccinations_Nulls,
    SUM(people_vaccinated IS NULL) AS PeopleVaccinated_Nulls,
    SUM(people_fully_vaccinated IS NULL) AS PeopleFullyVaccinated_Nulls
FROM portfolio_project.covidvaccinationupdated;

# Check key columns in both tables
SELECT *
FROM portfolio_project.coviddeathsupdated
WHERE location IS NULL
   OR `date` IS NULL;

SELECT *
FROM portfolio_project.covidvaccinationupdated
WHERE location IS NULL
   OR `date` IS NULL;
   
# Check date ranges in both tables
SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM portfolio_project.coviddeathsupdated;

SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM portfolio_project.covidvaccinationupdated;

/* =========================================================
    EXPLORATORY DATA ANALYSIS
   ========================================================= */

# Total cases vs total deaths
select Location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) as DeathPercentage
from portfolio_project.coviddeathsupdated
where location like '%states%'
and continent is not null
order by 1,2;

# Total cases vs Population
select Location, date, population, total_cases, round ((total_cases/population) * 100, 2)  as PercentPopulationInfected
from portfolio_project.coviddeathsupdated
where location like '%states%'
order by 1,2;

# Countries with highest infection rate 
SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       ROUND(
           MAX(total_cases / NULLIF(population, 0)) * 100,
           2
       ) AS PercentPopulationInfected
FROM portfolio_project.coviddeathsupdated
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

# Countries with highest death count
select Location, max(total_deaths)  as TotalDeathCount
from portfolio_project.coviddeathsupdated
where continent is not null
group by Location
order by TotalDeathCount desc;

# Continent-level locations with highest death counts
SELECT location,
       SUM(new_deaths) AS TotalDeathCount
FROM portfolio_project.coviddeathsupdated
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

/* =========================================================
   GLOBAL AND REGIONAL COVID-19 ANALYSIS
   ========================================================= */
   
# Global COVID-19 totals and overall death rate
SELECT
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    ROUND(
        SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100,
        2
    ) AS DeathPercentage
FROM portfolio_project.coviddeathsupdated
WHERE continent IS NOT NULL;

#Total deaths by continent-level location
SELECT
    location,
    SUM(new_deaths) AS TotalDeathCount
FROM portfolio_project.coviddeathsupdated
WHERE continent IS NULL
  AND location NOT IN
      ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

# Highest infection rate by location
SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(
        MAX(total_cases / NULLIF(population, 0)) * 100,
        2
    ) AS PercentPopulationInfected
FROM portfolio_project.coviddeathsupdated
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

# Infection percentage over time
SELECT
    location,
    population,
    `date`,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(
        MAX(total_cases / NULLIF(population, 0)) * 100,
        2
    ) AS PercentPopulationInfected
FROM portfolio_project.coviddeathsupdated
GROUP BY location, population, `date`
ORDER BY PercentPopulationInfected DESC;

/* =========================================================
   TOTAL POPULATION VERSUS VACCINATIONS
   ========================================================= */

# Join deaths and vaccination tables
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(COALESCE(vac.new_vaccinations, 0)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathsupdated AS dea
JOIN portfolio_project.covidvaccinationupdated AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

# CTE
WITH PopvsVac
(
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated
)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER
        (
            PARTITION BY dea.location
            ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM portfolio_project.coviddeathsupdated AS dea
    JOIN portfolio_project.covidvaccinationupdated AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

SELECT *,
       ROUND(
           (RollingPeopleVaccinated / NULLIF(population, 0)) * 100,
           2
       ) AS PercentPopulationVaccinated
FROM PopvsVac;

/* =========================================================
   TEMPORARY TABLE
   ========================================================= */
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    continent VARCHAR(255),
    location VARCHAR(255),
    `date` DATE,
    population DOUBLE,
    new_vaccinations DOUBLE,
    RollingPeopleVaccinated DOUBLE
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER
    (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.`date`
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathsupdated AS dea
JOIN portfolio_project.covidvaccinationupdated AS vac
    ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL;

SELECT *,
       ROUND(
           (RollingPeopleVaccinated / NULLIF(population, 0)) * 100,
           2
       ) AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

/* =========================================================
   VIEW FOR REPORTING AND ANALYSIS
   ========================================================= */

CREATE OR REPLACE VIEW vw_PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(COALESCE(vac.new_vaccinations, 0)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathsupdated AS dea
JOIN portfolio_project.covidvaccinationupdated AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



