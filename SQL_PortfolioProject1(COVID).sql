/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS --

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/Nullif(sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Australia'
where continent is not null
Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order By 2,3
)

--USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order By 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for Later Visulizations
USE PortfolioProject
go

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order By 2,3
