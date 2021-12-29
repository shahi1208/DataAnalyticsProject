Select * from PortfolioProject..CovidDeaths
where continent is not null order by 2,3,4

--SELECTING DATA THAT IM GONNA EXPLORE

select * from PortfolioProject..CovidVaccinations
select location,date,total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS THE RISK OF DYING BY THE DEATHRATE OF WHERE YOU LIVE
select location,date,population, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null and location  =   'india'
order by 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
select location,date, population, new_cases,total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- IN YOUR COUNTRY

select location,date, population, new_cases,total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location = 'india'
order by 1,2


-- LOOKING AT COUNTRIES WITH HIGEST INFECTION RATE COMPARED VS POPULATION

select location , population, max(total_cases) as hightestInfectionCount, max((total_cases/population))*100 as populationInfectedPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by  population, location
order by  4 desc

--LOOKING AT COUNTRIES WITH HIGHEST DEATH PERCENTAGE

select location ,population, max(cast(total_deaths as bigint)) as highestDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by highestDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- SHOWING THE TOTAL DEATH COUNT OF EACH CONTINENT

select  continent,   max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not  null
group by continent 
order by  TotalDeathCount desc

-- GLOBAL DEATH PERCENTAGE

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as globaldeathpercent
From PortfolioProject..CovidDeaths
where continent is not null --and location = 'india'
--Group By date

-- LOOKING AT NUMBER OF PEOPLE WHO GOT VACCINATED VS POPULATION

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USING CTE TO PERFORM THE CALCULATION ON PARTION BY IN PREVIOUS QUERY

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedpercent
From PopvsVac

 -- CRAETING TEMP TABLE TO PERFORM THE CALCULATION ON PARTION BY IN PREVIOUS QUERY

drop table if exists #globalvaccinatedpercent
create table #globalvaccinatedpercent (
continent nvarchar(255) ,location nvarchar(255),date datetime, population numeric,new_vaccinations numeric, Rollingpeoplevaccinated numeric
)

insert into  #globalvaccinatedpercent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedpercent
From #globalvaccinatedpercent

-- CREATING VIEWS TO STORE DATE FOR LATER VISUALIZATIONS

Create View globalvaccinatedpercent as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ordeer by 2,3

select * 
from  globalvaccinatedpercent

-- VIEWS #2

create view highestdeathcount as
select location ,population, max(cast(total_deaths as bigint)) as highestDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
--order by highestDeathCount desc

select * 
from highestdeathcount