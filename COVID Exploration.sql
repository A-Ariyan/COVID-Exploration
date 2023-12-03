Select *
From PortfolioProject..CovidDeaths
where continent is null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

--Select DATA that we are going to use
Select Location, date, total_cases, new_cases, total_deaths
From PortfolioProject..CovidDeaths
where continent is null
order by 1,2

--Changing the data type of the columns by ALTER

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN  total_cases float;

-- Looking at Pescentage of Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is null
Order by 1,2

--Looking at Pescentage of total Cases vs Total Deaths
--Where "state" is in the name of Location

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PescentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
Order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 
as PescentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PescentPopulationInfected desc

-- Showing countries with Highest Deth Count per population
-- Changing the data type by CAST

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
Order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases 
,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Having SUM(new_cases) != 0
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

with PopvsVac (continent, location, Date, Population, New_Vaccination, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table

Drop Table if exists #PercentPoplulationVaccinated
Create Table #PercentPoplulationVaccinated

(
continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPoplulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPoplulationVaccinated

--Creating View to store data for later visualizations
USE PortfolioProject
GO
Create view PercentPoplulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



