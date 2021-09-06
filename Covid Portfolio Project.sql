SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'India'
and continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs populations
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentInfectedPopulation
FROM PortfolioProject..CovidDeaths
Where location = 'India'
and continent IS NOT NULL
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCCount, Max((total_cases/population))*100 as PercentInfectedPopulation
FROM PortfolioProject..CovidDeaths
Group by location, population
ORDER BY PercentInfectedPopulation desc

--Showing countries with highest death count per population

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group by location
ORDER BY TotalDeathCount desc

--Let's break things down by continent

--Showing continents with highest death counts per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
Group by continent
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- total population vs vaccination

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(Convert(int, VAC.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 1,2,3


-- Use CTE
WITH PopvsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(Convert(int, VAC.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp table

DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(Convert(int, VAC.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- order by 1,2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated 
as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(Convert(int, VAC.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- order by 1,2,3

SELECT *
FROM PercentPopulationVaccinated