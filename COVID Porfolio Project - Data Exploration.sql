SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY location, date


--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths , population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY location, date


--Looking at Total Cases and Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like 'Vietnam' and continent is not null 
ORDER BY 1,2


--Looking at Total Cases and Population
--Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases, (total_deaths/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'Vietnam'
WHERE continent is not null 
ORDER BY 1,2



--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC



--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC



--LET'S BREAKING THINGS DOWN BY CONTINENT
--Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 



--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3



--Using CTE to perform Calculation on Partition By in previous query

WITH VacAndPop (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM VacAndPop



--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
