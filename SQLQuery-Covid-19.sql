SELECT
*
FROM
PortFolioProject..[covid-death]
ORDER BY 3,4

--SELECT
--*
--FROM
--PortFolioProject..[covid-vaccination]
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT
location, date, total_cases, new_cases, total_deaths, population
FROM
PortFolioProject..[covid-death]
ORDER BY 1,2

-- Looking at the Total cases vs total deaths
-- Show the dying of covid-19 in Sweden
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases)*100, 2) AS [death_percentage(%)]
FROM
PortFolioProject..[covid-death]
WHERE
location = 'Sweden'
ORDER BY 1,2

-- Looking at Total cases vs population
SELECT
date, population, total_cases, ROUND((total_cases / population)*100, 2) AS infection_rate
FROM
PortFolioProject..[covid-death]
Where
location = 'Sweden'
ORDER BY 1,2


-- Looking at countries with the highest infection rate
SELECT 
location, population, MAX(total_cases) AS latest_total_cases, MAX(ROUND((total_cases/population)*100, 4)) as infection_rate
FROM
PortFolioProject..[covid-death]
GROUP BY location, population
ORDER BY infection_rate desc

-- Showing death count by continent
SELECT
continent, MAX(CAST(total_deaths AS int)) AS total_deaths
FROM
PortFolioProject..[covid-death]
WHERE
continent IS NOT null
GROUP BY continent
ORDER BY total_deaths DESC

-- Showing death count in USA
SELECT
MAX(CAST(total_deaths AS int)) AS total_deaths
FROM
PortFolioProject..[covid-death]
WHERE
location = 'United States'

-- Showing death count in Canada
SELECT
MAX(CAST(total_deaths AS int)) AS total_deaths
FROM
PortFolioProject..[covid-death]
WHERE
location = 'Canada'

-- The total deaths of North America is wrong which includes the deaths from United States. The total deaths of Canada is missing

-- Showing countries with the highest death count per population
SELECT 
location, population, MAX(cast(total_deaths AS int)) AS latest_total_death, MAX(ROUND((total_deaths/population)*100, 4)) as death_rate
FROM
PortFolioProject..[covid-death]
WHERE
continent IS NOT null
GROUP BY location, population
ORDER BY death_rate desc

-- Showing the contients with the highest death per population
SELECT
continent, MAX(ROUND((total_deaths/population)*100, 4)) as death_rate
FROM 
PortFolioProject..[covid-death]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_rate DESC


-- Global numbers
SELECT
date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_death, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as death_rate
FROM 
PortFolioProject..[covid-death]
WHERE 
continent IS NOT NULL
AND
total_cases IS NOT NULL
AND
total_deaths IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at the total population vs vaccinations
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM
PortFolioProject..[covid-death] dea
JOIN PortFolioProject..[covid-vaccination] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE
dea.continent IS NOT NULL
AND
vac.new_vaccinations IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac(Continent, Location, Date, Population, NewVaccinations, PeopleVaccinated)
AS
(
	SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
	FROM
	PortFolioProject..[covid-death] dea
	JOIN PortFolioProject..[covid-vaccination] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE
	dea.continent IS NOT NULL
	AND
	vac.new_vaccinations IS NOT NULL
)
SELECT
*
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
	SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
	FROM
	PortFolioProject..[covid-death] dea
	JOIN PortFolioProject..[covid-vaccination] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE
	dea.continent IS NOT NULL
	AND
	vac.new_vaccinations IS NOT NULL
SELECT
*
FROM
#PercentPopulationVaccinated


-- Creating view to store data for later visulations
CREATE VIEW PercentPopulationVaccinated AS
	SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
	FROM
	PortFolioProject..[covid-death] dea
	JOIN PortFolioProject..[covid-vaccination] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE
	dea.continent IS NOT NULL
	AND
	vac.new_vaccinations IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated