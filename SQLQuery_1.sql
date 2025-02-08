select *
From PortfolioProject..CovidDeaths
order by 3, 4

-- select *
-- From PortfolioProject..CovidVaccinations
-- order by 3, 4

SELECT country, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
ORDER by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT country, 
       date, 
       total_cases, 
       total_deaths, 
      (total_deaths*1.0 / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE country = 'France'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT country, 
       date, 
       total_cases, 
       population, 
      (NULLIF(total_cases*1.0, 0)/population*1.0) * 100 AS GotCovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE country = 'France'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to Population
SELECT country, 
       population, 
        MAX(total_cases) as HighestInfectionCount, 
      MAX((NULLIF(total_cases*1.0, 0)/population*1.0)) * 100 AS PercentPOpulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE country = 'France'
GROUP BY country, population
ORDER BY PercentPOpulationInfected desc;

-- Showing Countries with Highest Death Count per population
SELECT country, MAX(cast(total_deaths as Int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE country = 'France'
GROUP BY country
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT
    SUM(total_cases * 1.0) AS TotalCases,
    SUM(new_deaths * 1.0) AS TotalNewDeaths,
    SUM(new_deaths * 1.0) / NULLIF(SUM(new_cases * 1.0), 0) * 100 AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
-- WHERE country = 'France'
-- GROUP BY
--     date
ORDER BY
1, 2


-- Looking at Total Population vs Vaccinations
SELECT
    vac.continent,
    dea.country,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.country ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.country = vac.country
    AND dea.date = vac.date
WHERE
    vac.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
ORDER BY
    dea.country, dea.date;

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT
    vac.continent,
    dea.country,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.country ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.country = vac.country
    AND dea.date = vac.date
WHERE
    vac.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
-- ORDER BY
--     dea.country, dea.date
)
select *, (RollingPeopleVaccinated / Population)* 100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

Insert Into #PercentagePopulationVaccinated
SELECT
    vac.continent,
    dea.country,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.country ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.country = vac.country
    AND dea.date = vac.date
WHERE
    vac.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
-- ORDER BY
--     dea.country, dea.date

select *, (RollingPeopleVaccinated / Population)* 100
FROM #PercentagePopulationVaccinated

-- Creating View to store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    vac.continent,
    dea.country,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.country ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.country = vac.country
    AND dea.date = vac.date
WHERE
    vac.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL;


SELECT * FROM PercentPopulationVaccinated