SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL  #Removing obervations where continent has null value but has continent name in the region column instead of the country name
	
--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations 
--ORDER BY 3,4

-- Selecting Data to be used 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if someone contracted COVID in Germany

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
AND location = 'Germany'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows the percentage of German population that got infected with COVID 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
AND location = 'Germany'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate

SELECT location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS MaximumInfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
--WHERE location = 'Germany'
GROUP BY location, population
ORDER BY MaximumInfectionRate DESC

-- Showing Countries with Highest Death Count 

SELECT location, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
--WHERE location = 'Germany'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breaking things down by Continent 
-- Showing contintents with the highest death count

SELECT continent, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
--WHERE location = 'Germany'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Continent with the Highest Death Count

SELECT continent, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
--WHERE location = 'Germany'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date 
ORDER BY 1,2

--Exploring Vaccination Data

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccination
FROM PopvsVac

--Creating View to store Data for Visualizations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
