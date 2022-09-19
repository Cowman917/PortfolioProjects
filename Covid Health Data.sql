-- Shows Mortality rate for each country on a daily basis
 
use PortfolioProject
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Mortality Rate"
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null
order by 1,2;



-- Looking at total cases vs population in the United States


use PortfolioProject
SELECT Location, date, total_cases, total_deaths, (total_cases/population)*100 as 'Percentage of infected population'
FROM PortfolioProject.dbo.CovidDeaths$
where location = 'United States' and Continent is not null
order by 1,2;


-- looking at countries with highest infection rate 


use PortfolioProject
SELECT location, Population, Max(total_cases) as  HighestInfectionCount, Max((total_cases/population)*100) as PercentageOfInfectedPopulation
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null
group by location, population
order by PercentageOfInfectedPopulation desc


-- Showing Countries with Highest Death Count\


USE PortfolioProject
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null 
group by location
Order by TotalDeathCount desc 


-- showing Total Death Count for world by continent using correct numbers and removing inclome class results


USE PortfolioProject
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is  null AND  location NOT IN ('Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location
Order by TotalDeathCount desc


--showing Total Death Count by Continent


USE PortfolioProject
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null 
group by continent
Order by TotalDeathCount desc


-- Global Numbers for Total cases and Total Deaths per day 


use PortfolioProject
SELECT  date, SUM(new_cases) as 'Total Cases', SUM(cast(new_deaths as int)) as 'Total Deaths', 
 SUM(cast(New_deaths as int))/Sum(New_cases)*100 as 'Mortality Rate'
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null
Group by date
order by 1,2


-- Global Numbers for Total cases and Total Deaths overall

use PortfolioProject
SELECT  SUM(new_cases) as 'Total Cases', SUM(cast(new_deaths as int)) as 'Total Deaths', 
 SUM(cast(New_deaths as int))/Sum(New_cases)*100 as 'Mortality Rate'
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent is not null
order by 1


-- Looking at Total Population of countries vs Total Vacinations


select dea.continent as 'Continent',  dea.location as 'Location', dea.date as 'Date', dea.population as 'Population', vac.new_vaccinations as 'New Vaccinations', 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as 'Total Vaccinations by Date'
From PortfolioProject.dbo.CovidDeaths$ as dea
JOIN PortfolioProject.dbo.CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
Order by  dea.location, dea.date



--USE CTE to find the rolling vacination rate for countries. Data doesn't differentiate between boosters and people receiveing first dose so RollingVaccinations becomes useless number when boosters become available


With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent as 'Continent',  dea.location as 'Location', dea.date as 'Date', dea.population as 'Population', vac.new_vaccinations as 'New Vaccinations', 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVacinations
FROM PortfolioProject.dbo.CovidDeaths$ as dea
JOIN PortfolioProject.dbo.CovidVaccinations$ as vac
	on  dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
-- Order by  dea.location, dea.date
)

select * , (RollingPeopleVaccinated/Population)*100 as 'Vacination Rate'
From PopVsVac



-- Temp Tables


Drop Table if exists #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVacinated

select dea.continent as 'Continent',  dea.location as 'Location', dea.date as 'Date', dea.population as 'Population', vac.new_vaccinations as 'New Vaccinations', 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVacinations
From PortfolioProject.dbo.CovidDeaths$ as dea
JOIN PortfolioProject.dbo.CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
-- Order by  dea.location, dea.date

select * , (RollingPeopleVaccinated/Population)*100 as 'Vacination Rate'
From #PercentPopulationVacinated




-- Creating View to Store data for later visualizations

CREATE VIEW PercentPopulationVacinated as

select dea.continent as 'Continent',  dea.location as 'Location', dea.date as 'Date', dea.population as 'Population', vac.new_vaccinations as 'New Vaccinations', 
	SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVacinations
From PortfolioProject.dbo.CovidDeaths$ as dea
JOIN PortfolioProject.dbo.CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--Order by  dea.location, dea.date

SELECT *
FROM PercentPopulationVacinated
