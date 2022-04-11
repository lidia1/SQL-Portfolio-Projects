-- COVID DEATH TABLE
Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- It shows the likelihood of dying if you had covid in my country
Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Albania' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows what % of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like 'Albania'
order by 1,2

--Countries with highest infection rate
Select Location, population, MAX(total_cases) AS HighestInfection_Count,
MAX((total_cases/population))*100  AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Looking the countries with the highest death count
Select Location,  MAX(cast(total_deaths as INT)) AS HighestDeath_Count
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by HighestDeath_Count  desc

--Looking data by continent
Select continent,  MAX(cast(total_deaths as INT)) AS HighestDeath_Continent
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by HighestDeath_Continent  desc

-- New cases day by day on global numbers
select date, SUM(new_cases)
From PortfolioProject..CovidDeaths
where continent is not null
group By date
order by 1,2

--global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group By date
order by 1,2


--COVID VACCINATION TABLE
Select*
from PortfolioProject..CovidVaccinations

--Joining two tables together
Select*
from PortfolioProject..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
     On dea.location = vac.location
	 and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--TEMP TABLE to see the % of people vaccinated

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select*, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated



--Creating view to store data for late visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *
	From PercentPopulationVaccinated