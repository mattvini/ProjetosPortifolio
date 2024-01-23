select *
from CovidDeaths
--where continent is not NULL
order by 1,2

--Total Cases vs Total Deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'Brazil' and continent is not NULL


--Total Cases vs Population
select location, date, total_cases,population, (total_cases/population)*100 as PercentageOfInfection
from CovidDeaths
where continent is not NULL
--where location = 'Brazil'
order by 1,2


--Country with highest infection Rates
select location,population,max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentageOfInfection
from CovidDeaths
where continent is not NULL
--where location='Australia'
group by location,population
order by 4 desc

--Country with highest death count
select location,max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by HighestDeathCount desc


--CONTINENTS with highest death count
select location,max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is NULL
group by location
order by HighestDeathCount desc

--Worldwide Total Cases vs Total Deaths
select sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL


--Join Death table and Vaccination Table

select death.continent, death.location, death.date, population, vacin.new_vaccinations, vacin.total_vaccinations, 
SUM(cast(vacin.new_vaccinations as int)) over (partition by death.location order by death.location) as TotalVaccinated
from CovidDeaths death
join CovidVaccinations vacin
	on death.location=vacin.location and death.date=vacin.date
where death.continent is not NULL
order by 2,3


--CTE
with populationvsvaccination (continent, location, date, population, new_vaccinations,TotalVaccinated)
as
(
select death.continent, death.location, death.date, population, vacin.new_vaccinations, 
SUM(cast(vacin.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as TotalVaccinated
from CovidDeaths death
join CovidVaccinations vacin
	on death.location=vacin.location and death.date=vacin.date
where death.continent is not NULL
)
select *, (TotalVaccinated/population)*100 as PercentageVaccinated
from populationvsvaccination
order by 2,3


--For later visualization

create view DeathCountperContinent as
select location,max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is NULL
group by location
